# バミリ

音源に合わせてダンスのフォーメーションを作り、リンクでメンバーと共有するWebアプリです。
メンバーはアカウント登録なしで、送られたリンクを開くだけで使えます（iPhone / Android / iPad / パソコン）。

## 共有のしかた（設定なし）

1. 振付担当が「新しい作品」を作り、音源・隊形・メモを入れる
2. 「共有」→ **メンバー用リンク** をコピーして LINE などで送る（作品データはリンクそのものに入っています）
3. メンバーはリンクを開くだけ。最初に1回、自分の端末で音源を読み込む → 練習モードで自分をタップすると強調される
4. 直したら、もう一度リンクを送る → メンバーの端末で新しい版に置き換わる（読み込んだ音源はそのまま）

- 音源や写真もまとめて渡したいときは「まるごとファイル」を送り、受け取った人は「作品データを読み込む」で開く
- 編集を別の人に渡すときは「編集を引き継ぐリンク」を送る（同時編集ではなくコピー）
- メンバーには PDF（一覧＋隊形ごとのページ）を送ることもできる

ホーム画面に追加するとアプリのように使えます（iPhone: Safari の共有ボタン →「ホーム画面に追加」）。

## （任意）リアルタイム共有にする

複数人で同時に編集したい、音源や写真もリンクだけで届けたい場合は、以下の Supabase 設定をすると
「保存するとメンバー側に数秒で反映される」方式に切り替わります。設定しなくても上の方法で使えます。

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
