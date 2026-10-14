-- バミリ: Supabase の初期設定
-- Supabase ダッシュボード → SQL Editor → New query に全部貼り付けて「Run」を押す。
-- 何度実行しても壊れないように書いてあります。

create extension if not exists pgcrypto with schema extensions;

-- 作品データ（1作品 = 1行）。編集用の鍵はハッシュだけを保存する。
create table if not exists public.projects (
  id          text primary key,
  edit_hash   text not null,
  data        jsonb not null,
  ver         bigint not null default 1,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- テーブルを直接は読めない・書けないようにして、下の関数経由だけで扱う
alter table public.projects enable row level security;
revoke all on table public.projects from anon, authenticated;

-- 作品を読む（作品IDを知っている人だけ）
create or replace function public.bm_get(pid text)
returns json language sql stable security definer set search_path = public, extensions as $$
  select json_build_object('data', data, 'ver', ver, 'updated_at', updated_at)
  from public.projects where id = pid;
$$;

-- 更新の有無だけを軽く確認する（5秒ごとに呼ばれる）
create or replace function public.bm_ver(pid text)
returns bigint language sql stable security definer set search_path = public, extensions as $$
  select ver from public.projects where id = pid;
$$;

-- 作品が存在するか（写真・音源のアップロード許可に使う）
create or replace function public.bm_exists(pid text)
returns boolean language sql stable security definer set search_path = public, extensions as $$
  select exists (select 1 from public.projects where id = pid);
$$;

-- 新しい作品を作る
create or replace function public.bm_create(pid text, ekey text, pdata jsonb)
returns bigint language plpgsql security definer set search_path = public, extensions as $$
begin
  if pid !~ '^[a-z0-9]{10,40}$' or length(ekey) < 16 then raise exception 'bad arguments'; end if;
  if octet_length(pdata::text) > 2000000 then raise exception 'too large'; end if;
  insert into public.projects (id, edit_hash, data) values (pid, encode(extensions.digest(ekey, 'sha256'), 'hex'), pdata);
  return 1;
end $$;

-- 保存する（編集用の鍵が合うときだけ）
create or replace function public.bm_save(pid text, ekey text, pdata jsonb)
returns bigint language plpgsql security definer set search_path = public, extensions as $$
declare v bigint;
begin
  if octet_length(pdata::text) > 2000000 then raise exception 'too large'; end if;
  update public.projects
     set data = pdata, ver = ver + 1, updated_at = now()
   where id = pid and edit_hash = encode(extensions.digest(ekey, 'sha256'), 'hex')
  returning ver into v;
  if v is null then raise exception 'forbidden'; end if;
  return v;
end $$;

-- 編集用の鍵が正しいか確認する
create or replace function public.bm_check(pid text, ekey text)
returns boolean language sql stable security definer set search_path = public, extensions as $$
  select exists (select 1 from public.projects where id = pid and edit_hash = encode(extensions.digest(ekey, 'sha256'), 'hex'));
$$;

-- 作品を削除する（編集用の鍵が合うときだけ）
create or replace function public.bm_delete(pid text, ekey text)
returns boolean language plpgsql security definer set search_path = public, extensions as $$
declare n int;
begin
  delete from public.projects where id = pid and edit_hash = encode(extensions.digest(ekey, 'sha256'), 'hex');
  get diagnostics n = row_count;
  if n = 0 then raise exception 'forbidden'; end if;
  return true;
end $$;

grant execute on function public.bm_get(text), public.bm_ver(text), public.bm_exists(text),
  public.bm_create(text, text, jsonb), public.bm_save(text, text, jsonb),
  public.bm_check(text, text), public.bm_delete(text, text) to anon, authenticated;

-- 音源・写真の置き場所（リンクを知っている人が読める。最大50MB、音声と画像のみ）
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media', 'media', true, 52428800, array['audio/*', 'image/*', 'video/mp4', 'video/webm'])
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

-- アップロードは「実在する作品のフォルダ」にだけ許可（上書き・削除は不可）
drop policy if exists "bamiri upload media" on storage.objects;
create policy "bamiri upload media" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'media' and public.bm_exists((storage.foldername(name))[1]));
