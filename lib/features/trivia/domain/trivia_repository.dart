import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'trivia_item.dart';

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  return TriviaRepository();
});

class TriviaRepository {
  final Random _random = Random();

  final List<TriviaItem> _data = const [
    // --- History & Origins ---
    TriviaItem(
      category: 'History',
      content: 'ルービックキューブは1974年にエルノー・ルービックによって発明されました。',
    ),
    TriviaItem(
      category: 'History',
      content: '当初の名前は「マジック・キューブ (Magic Cube)」でした。',
    ),
    TriviaItem(
      category: 'History',
      content: '1980年に「Rubik\'s Cube」として国際的に発売され、世界的なブームとなりました。',
    ),
    TriviaItem(
      category: 'History',
      content: '最初の世界大会は1982年にブダペストで開催され、Minh Thaiが22.95秒で優勝しました。',
    ),
    TriviaItem(
      category: 'History',
      content: '発明者のエルノー・ルービックは、最初は自分の作ったパズルを解くのに約1ヶ月かかりました。',
    ),
    TriviaItem(
      category: 'History',
      content: 'ルービックキューブは、建築学の教授だったルービックが「3次元の動き」を学生に説明するために考案しました。',
    ),
    TriviaItem(
      category: 'History',
      content: '世界で最も売れた「おもちゃ」としてギネス記録に認定されています。販売数は4億5000万個以上と言われます。',
    ),
    TriviaItem(category: 'History', content: '日本での発売開始は1980年7月25日でした。'),
    TriviaItem(
      category: 'History',
      content:
          '1981年、 パトリック・ボサートという12歳の少年が書いた攻略本'
          '「You Can Do the Cube」がベストセラーになりました。',
    ),
    TriviaItem(
      category: 'History',
      content:
          '2014年、Googleはルービックキューブ誕生40周年を記念して'
          'Doodle（トップロゴ）を遊べるキューブにしました。',
    ),

    // --- Mathematics & Mechanics ---
    TriviaItem(
      category: 'Math',
      content: '3x3x3キューブの組み合わせ総数は4325京2003兆2744億8985万6000通りです。',
    ),
    TriviaItem(
      category: 'Math',
      content: '「God\'s Number (神の数字)」は「20」です。どんな配置からでも最短20手以内で揃えることが可能です。',
    ),
    TriviaItem(
      category: 'Math',
      content: 'もし毎秒1パターン試しても、全てのパターンを試すには宇宙の年齢以上の時間がかかります。',
    ),
    TriviaItem(
      category: 'Math',
      content: 'センターパーツは動きません（位置関係が固定されています）。白の裏は常に黄色です。',
    ),
    TriviaItem(
      category: 'Math',
      content: 'ルービックキューブは群論（Group Theory）という数学の分野でよく研究対象になります。',
    ),
    TriviaItem(
      category: 'Math',
      content: '6面完成状態からランダムに回転させていくと、理論上はいつか必ず元の状態に戻ります（とてつもなく長い時間がかかりますが）。',
    ),
    TriviaItem(
      category: 'Math',
      content: '「デビルズ・アルゴリズム」とは、繰り返すとすべてのパターンを経由して元に戻るという仮説上の手順のことです。',
    ),
    TriviaItem(
      category: 'Mechanics',
      content: 'コーナーパーツは8個、エッジパーツは12個、センターパーツは6個あります。',
    ),
    TriviaItem(
      category: 'Mechanics',
      content: '分解するとわかりますが、内部には球状のコア構造があります（特に最近のスピードキューブ）。',
    ),
    TriviaItem(
      category: 'Math',
      content: '偶置換と奇置換の概念により、コーナーだけを1つ捻ったり、エッジを1つだけ反転させることは不可能です（分解しない限り）。',
    ),

    // --- Records (World) ---
    TriviaItem(
      category: 'Record',
      content: '3x3単発の世界記録はMax Parkによる3.13秒です(2023年)。',
    ),
    TriviaItem(
      category: 'Record',
      content: '3x3平均(Ao5)の世界記録はYiheng Wangによる4.25秒です(2024年)。',
    ),
    TriviaItem(
      category: 'Record',
      content:
          '目隠し(3x3 BLD)の世界記録は、Tommy Cherryによる12.00秒(2024年)などの驚異的なタイムが出ています。',
    ),
    TriviaItem(
      category: 'Record',
      content: '最小手数競技(FMC)では、20手以下で揃える記録も珍しくありません。',
    ),
    TriviaItem(
      category: 'Record',
      content: '片手(OH)の世界記録は6秒台前半です。両手で揃える一般人の平均より遥かに速いです。',
    ),
    TriviaItem(
      category: 'Record',
      content: '足で揃える(With Feet)競技はかつて存在しましたが、2019年にWCA公式種目から削除されました。',
    ),
    TriviaItem(category: 'Record', content: '4x4x4の世界記録単発は15秒台、5x5x5は32秒台です。'),
    TriviaItem(
      category: 'Record',
      content: 'ロボットによる最速記録は0.3秒台です（三菱電機のロボットなど）。',
    ),
    TriviaItem(category: 'Record', content: 'ジャグリングしながらキューブを揃えるギネス記録も存在します。'),
    TriviaItem(
      category: 'Record',
      content: '水中での最速記録や、スカイダイビング中の記録など、多くの変わり種記録があります。',
    ),

    // --- Methods & Techniques ---
    TriviaItem(
      category: 'Method',
      content: '最も一般的な解法はCFOP (Cross, F2L, OLL, PLL) メソッドです。',
    ),
    TriviaItem(
      category: 'Method',
      content: 'Rouxメソッドは、ブロックビルディングを主体とし、回転記号M（中層）を多用する解法です。',
    ),
    TriviaItem(
      category: 'Method',
      content: 'ZZメソッドは、最初にエッジの向きを全て正す(EO)ことで、持ち替えをなくす解法です。',
    ),
    TriviaItem(
      category: 'Method',
      content: '初心者向け解法(LBL法)は「Layer By Layer」の略で、1段ずつ揃えていく手法です。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「Lookahead (先読み)」とは、現在の手順を回しながら、次のパーツの動きを目で追う技術です。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「Finger Trick」とは、手首を使わずに指先だけで素早く回す技術のことです。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「Regrip」とは、回しやすいように持ち手を変える動作のこと。これを減らすのが速くなるコツです。',
    ),
    TriviaItem(
      category: 'Technique',
      content: 'OLL (Orientation of the Last Layer) は57種類の手順があります。',
    ),
    TriviaItem(
      category: 'Technique',
      content: 'PLL (Permutation of the Last Layer) は21種類の手順があります。',
    ),
    TriviaItem(
      category: 'Method',
      content:
          '目隠し競技では、Old PochmannやM2、3-Style（Commutator）といった専用の記憶・解法メソッドが使われます。',
    ),

    // --- Hardware & Reviews ---
    TriviaItem(
      category: 'Hardware',
      content: 'GAN 14 MagLevは、バネの代わりに磁石の反発力(MagLev)を使い、摩擦を極限まで減らしています。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: 'MoYu WeiLong WRM V9は、強力な磁力アシスト（Ball-Core）で自動的に層が揃う感覚が特徴です。',
    ),
    TriviaItem(
      category: 'Hardware',
      content:
          '「コーナーカット」とは、層が完全に揃っていなくても、無理やり縦に回せる性能のことです。現代のキューブは45度以上でもカットできます。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: '初期のルービックキューブは動きが固く、回すのに力が必要でした。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: '現在のスピードキューブは、内部に磁石が搭載されており、ピタッと止まるアシスト機能が標準的です。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: 'シリコンスプレーなどの潤滑剤(Lube)を差すことで、回転の軽さや滑らかさを調整します。',
    ),
    TriviaItem(
      category: 'Hardware',
      content:
          'Smart Cube (Bluetooth搭載キューブ) は、スマホアプリと連動して回転を分析したり、オンライ対戦ができます。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: 'ステッカーレス（プラスチック自体に色がついている）キューブは、かつて大会で使用禁止でしたが、2015年に解禁されました。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: '「UVコート」されたキューブは、表面が光沢がありグリップ力（指への吸い付き）が高いと人気です。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: '世界最小のルービックキューブは数ミリメートル、最大は数メートルのオブジェなどがあります。',
    ),

    // --- WCA & Competitions ---
    TriviaItem(
      category: 'WCA',
      content: 'WCAは「World Cube Association」の略で、世界中の公式大会を管理する組織です。',
    ),
    TriviaItem(category: 'WCA', content: '公式大会では「インスペクション（観察）」時間が最大15秒与えられます。'),
    TriviaItem(
      category: 'WCA',
      content: '競技では、スタックマットタイマーという専用のタイマーに両手を置いて計測を開始します。',
    ),
    TriviaItem(
      category: 'WCA',
      content: '公式記録として認定されるには、WCAデリゲート（役員）の立ち会いが必要です。',
    ),
    TriviaItem(
      category: 'WCA',
      content: 'ジャッジ（審判）は、選手が試技を終えた後にパズルが正しく揃っているか、+2秒ペナルティがないかを確認します。',
    ),
    TriviaItem(
      category: 'WCA',
      content: 'キューブが揃っていても、層が45度以上ズレていると「+2秒」のペナルティになります。',
    ),
    TriviaItem(
      category: 'WCA',
      content: 'インスペクション時間を過ぎてからスタートすると+2秒、さらに遅れるとDNF(失格)になります。',
    ),
    TriviaItem(
      category: 'WCA',
      content: '公式大会に参加するのに年齢制限はありません。3歳の参加者も80歳以上の参加者もいます。',
    ),
    TriviaItem(
      category: 'WCA',
      content: 'パズルのスクランブル（崩し手順）は、コンピュータプログラムによってランダムに生成されます。',
    ),
    TriviaItem(
      category: 'WCA',
      content: '多くの種目では「Ao5 (Average of 5)」形式が採用され、最高と最低を除いた3回の平均が記録となります。',
    ),

    // --- Variations & Puzzles ---
    TriviaItem(
      category: 'Puzzle',
      content: '2x2x2キューブは「ポケットキューブ (Pocket Cube)」とも呼ばれます。',
    ),
    TriviaItem(
      category: 'Puzzle',
      content: '4x4x4キューブは「リベンジ (Rubik\'s Revenge)」と呼ばれます。',
    ),
    TriviaItem(
      category: 'Puzzle',
      content: '5x5x5キューブは「プロフェッサー (Professor\'s Cube)」と呼ばれます。',
    ),
    TriviaItem(category: 'Puzzle', content: 'ピラミンクス(Pyraminx)は正四面体のパズルです。'),
    TriviaItem(
      category: 'Puzzle',
      content: 'メガミンクス(Megaminx)は正十二面体のパズルで、12の面があります。',
    ),
    TriviaItem(
      category: 'Puzzle',
      content: 'スキューブ(Skewb)は、頂点を中心に回転する独特な動きをするパズルです。',
    ),
    TriviaItem(
      category: 'Puzzle',
      content: 'スクエアワン(Square-1)は、回転すると形が変わる「シェイプシフティング」パズルです。',
    ),
    TriviaItem(
      category: 'Puzzle',
      content: 'クロック(Rubik\'s Clock)は、両面の針をすべて12時に合わせる競技です。',
    ),
    TriviaItem(category: 'Puzzle', content: '6x6や7x7などの大型キューブも公式競技として存在します。'),
    TriviaItem(
      category: 'Puzzle',
      content: '非公式ですが17x17x17やそれ以上の巨大なキューブも製品化されています。',
    ),

    // --- Culture & Funny ---
    TriviaItem(
      category: 'Culture',
      content: '映画『幸せのちから』では、ウィル・スミス演じる主人公がルービックキューブを解くシーンが重要に描かれています。',
    ),
    TriviaItem(
      category: 'Culture',
      content: '映画『スノーデン』では、機密データを持ち出すためのカモフラージュとしてルービックキューブが使われました。',
    ),
    TriviaItem(
      category: 'Culture',
      content: 'Justin Bieberはかつてルービックキューブを2分以内で解く特技をテレビで披露しました。',
    ),
    TriviaItem(
      category: 'Culture',
      content: 'ストリートアーティスト「Invader」は、ルービックキューブを使ってモザイク画を描く「Rubikcubism」で有名です。',
    ),
    TriviaItem(
      category: 'Culture',
      content:
          'Netflixのドキュメンタリー『スピードキューバーズ』は、Max Parkと'
          'Feliks Zemdegsの友情を描いた感動的な作品です。',
    ),
    TriviaItem(
      category: 'Funny',
      content: '1x1x1キューブは、何もしなくても完成しているので解くのに0秒かかります（ジョークパズルとして人気です）。',
    ),
    TriviaItem(
      category: 'Funny',
      content: '初心者が「1面だけ揃った！」と言うとき、側面の色が合っていないことがよくあります。',
    ),
    TriviaItem(
      category: 'Culture',
      content: '多くの人はシールを剥がして貼り直した経験がありますが、今の競技用キューブはタイルやプラスチック成形なのでできません。',
    ),
    TriviaItem(category: 'Lingo', content: '「PB」とは「Personal Best（自己ベスト）」の略です。'),
    TriviaItem(
      category: 'Lingo',
      content: '「DNF」は「Did Not Finish（記録なし/失格）」の略です。',
    ),

    // --- More Facts ---
    TriviaItem(
      category: 'Knowledge',
      content: 'ルービックキューブの内部メカニズムは、実は3つの軸が交差する「スパイダー」と呼ばれる部品が支えています（旧型）。',
    ),
    TriviaItem(
      category: 'Knowledge',
      content: 'スピードキューブ界では「GAN」「MoYu」「QiYi」が3大メーカーと言われています。',
    ),
    TriviaItem(
      category: 'History',
      content: '1980年代のブーム時には「キューブ依存症」という言葉が生まれるほど流行しました。',
    ),
    TriviaItem(
      category: 'Math',
      content: '最短手順を見つけるプログラムは「Solver」と呼ばれ、Kociemba Algorithmなどが有名です。',
    ),
    TriviaItem(
      category: 'Record',
      content: '目隠し競技では、最初にキューブの配置を記憶してから目隠しをして解きます。記憶時間もタイムに含まれます。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「Color Neutral (カラーニュートラル)」とは、白面以外（黄色、青など）からもスタートできるスキルのことです。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「TPS」は「Turns Per Second」の略で、1秒間に何回転させたかという速さの指標です。',
    ),
    TriviaItem(
      category: 'Lingo',
      content: '「Pop (ポップ)」とは、回転中にパーツが外れて飛び散ってしまう事故のことです。',
    ),
    TriviaItem(
      category: 'Lingo',
      content: '「Lock up (ロックアップ)」とは、パーツが引っかかって回らなくなることです。',
    ),
    TriviaItem(
      category: 'Lingo',
      content: '「Skip (スキップ)」とは、OLLやPLLの手順が偶然揃っていて、その工程を飛ばせるラッキーな現象です。',
    ),
    TriviaItem(
      category: 'Lingo',
      content: '「Non-Cuber」とは、キューブを解けない一般の人たちのことを指すスラングです。',
    ),
    TriviaItem(
      category: 'Math',
      content: 'Superflipと呼ばれるパターンは、すべてのエッジが反転している状態で、God\'s Numberの20手が必要です。',
    ),
    TriviaItem(
      category: 'Variation',
      content: 'ミラーキューブは、色の代わりにパーツの「大きさ」が異なるパズルです。',
    ),
    TriviaItem(
      category: 'Variation',
      content: 'ゴーストキューブは、変則的なカッティングがされた非常に難易度の高いパズルです。',
    ),
    TriviaItem(
      category: 'History',
      content: 'ルービック氏は、元々「視覚的な思考」を教えるための教材としてキューブを作りました。',
    ),
    TriviaItem(
      category: 'Culture',
      content: 'Googleの入社試験に「ルービックキューブについて語れ」というような問題が出たという噂があります。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: '磁石の強さを調整できる機能は、今のフラッグシップモデルでは当たり前になっています。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: '最近はバネの代わりに「MagLev（磁気浮上）」を使うことで摩擦を減らす技術がトレンドです。',
    ),
    TriviaItem(
      category: 'Technique',
      content: 'F2L (First 2 Layers) は、コーナーとエッジをペアにして同時にスロットに入れる技術です。',
    ),
    TriviaItem(
      category: 'Record',
      content: '複数目隠し(Multi-Blind)では、1時間以内にいくつのキューブを目隠しで連続正解できるかを競います。',
    ),
    TriviaItem(category: 'WCA', content: '世界大会は2年に1回開催されます。'),
    TriviaItem(
      category: 'WCA',
      content: 'アジア大会やヨーロッパ大会など、大陸ごとのチャンピオンシップも開催されています。',
    ),
    TriviaItem(
      category: 'Japan',
      content: '日本大会(Japan Championship)は毎年開催されています。',
    ),
    TriviaItem(
      category: 'Japan',
      content: '日本のスピードキューブ界隈は、JRCA（日本ルービックキューブ協会）が統括しています。',
    ),
    TriviaItem(category: 'Trivia', content: 'ルービックキューブは「ハンガリーの至宝」とも呼ばれています。'),
    TriviaItem(
      category: 'Trivia',
      content: '「Speedcubing」という単語は、ケンブリッジ辞書にも登録されています。',
    ),
    TriviaItem(
      category: 'Trivia',
      content: '2020年代に入り、キューブ人口はYouTubeやTikTokの影響で再燃・急増しています。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「X-Cross」とは、クロスの段階でF2Lの1つ目のペアも同時に揃えてしまう上級テクニックです。',
    ),
    TriviaItem(
      category: 'Technique',
      content: '「Keyhole」メソッドは、あえて1箇所空けておくことで他のパーツを入れやすくする古典的テクニックです。',
    ),
    TriviaItem(
      category: 'Hardware',
      content: 'メンテナンスとして、ネジを緩めたり締めたりして「Tension」を調整することが重要です。',
    ),
    TriviaItem(
      category: 'Math',
      content: 'ルービックキューブの配色は「Standard Color Scheme」と呼ばれ、現在はほぼ統一されています。',
    ),
  ];

  TriviaItem fetchRandomTrivia() {
    return _data[_random.nextInt(_data.length)];
  }
}
