# バミリ

音源に合わせてダンスのフォーメーションを作り、リンクでメンバーと共有するWebアプリです。
メンバーはアカウント登録なしで、送られたリンクを開くだけで使えます（iPhone / Android / iPad / パソコン）。

## 使い方の流れ

1. 振付担当が「新しい作品」を作り、音源・隊形・メモ・写真を入れる
2. 「共有」から **メンバー用リンク** を LINE などで送る
3. メンバーはリンクを開いて「練習モード」で自分をタップ → 自分の位置と次の移動先が強調される
4. 一緒に編集する人には **編集用リンク** を送る（知っている人は誰でも編集できるので注意）

ホーム画面に追加するとアプリのように使えます（iPhone: Safari の共有ボタン →「ホーム画面に追加」）。

## 初期設定（最初に1回だけ）

### 1. Supabase（データの置き場所・無料）

1. https://supabase.com で「Start your project」→ GitHub アカウントでサインイン
2. 「New project」→ 名前は `bamiri`、Region は **Northeast Asia (Tokyo)**、パスワードは「Generate」でOK →「Create new project」
3. 左メニューの **SQL Editor** →「New query」に [`supabase-setup.sql`](supabase-setup.sql) の中身を全部貼り付けて **Run**
4. **Project Settings → API Keys**（または Data API）で次の2つをコピー
   - Project URL（`https://xxxx.supabase.co`）
   - Publishable key（`sb_publishable_...`）または anon public key（`eyJ...`）
5. [`config.js`](config.js) に貼り付ける（**service_role / secret キーは絶対に入れない**）

### 2. 公開（GitHub Pages）

このフォルダを GitHub に push し、Settings → Pages で `main` ブランチのルートを公開します。

## 注意

- Supabase の無料プランは、**1週間まったく使われないと一時停止**します。止まったら Supabase のダッシュボードで「Restore」を押せば戻ります。
- メンバー用リンクを知っている人は誰でも見られます。リンクは関係者だけに送ってください。
- 音源は1ファイル50MBまで。市販曲の音源はメンバー内の練習用にとどめてください。
