#import "config.typ": *

#show: conf.with(
  title: [
    aaa
  ],
)

// #figure(
//   caption: "",
//   image("", width: 150mm),
// )<>
#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
)

#title-slide[
  = FPGAを用いたアルゴリズム実装 中間報告
  #v(2em)


  電子情報工学科3年 太田智也

  #datetime.today().display()
]


== 課題1 (ルーレット)

#slide[
  - 1-A: `SW[1:0]` に応じた速度で7segを回転させる
  - 1-B: `SW[2]` の入力を追加し、これに応じて回転方向を変える

  #grid(
    columns: 2,
    gutter: 2cm,
    [#figure(
      caption: "課題1の動作例",
      image("img/roulette.gif", height: 70mm),
    )<resource1>],
    [#figure(
      caption: "逆回転部分のコード",
      sourcecode[
        ```verilog
        end else if( cntout1 == 0 && cntout0 == 1 ) begin
            if(dir == 0) begin
              rr <= {rr[4:0],rr[5]};
            end else begin
              rr <= {rr[0],rr[5:1]};
            end
        ```],
    )<code1>],
  )
]


== 課題1 (ルーレット)

#slide[
  - リソース・性能はあまり変化せず
  - fanoutは増加した
  #grid(
    columns: 2,
    gutter: 2cm,
    [#figure(
      caption: "課題1の使用リソース",
      table(
        columns: 3,
        table.header([], [1-A], [1-B]),
        [Logic usage], [24], [24],
        [ALUT usage], [43], [43],
        [Dedicated logic reg], [39], [39],
        [IO pins], [15], [#text(fill: red)[16]],
        [Max fanout], [39], [39],
        [Total fanout], [245], [#text(fill: red)[258]],
        [Ave fanout], [2.19], [2.26],
      ),
    )<resource1>],
    [#figure(
      caption: "課題1の最大動作周波数(@1.1V, 0℃)",
      table(
        columns: 3,
        table.header([], [1-A], [1-B]),
        [CLOCK_50], [389.71 MHz], [388.95 MHz],
      ),
    )<freq1>],
  )
]

== 課題2 (リモコンと電卓)

#slide[
  - リモコンの信号を受信し、四則演算の結果を7segに表示する
  - どのリソースも課題1より大幅に増加し、DSPが1つ使用された
  #grid(
    columns: 2,
    gutter: 2cm,
    [#figure(
      caption: "課題2の使用リソース",
      table(
        columns: 2,
        table.header([], [2]),
        [Logic usage], [576],
        [ALUT usage], [1109],
        [Dedicated logic reg], [188],
        [IO pins], [69],
        [Total DSP blocks], [#text(fill: red)[1]],
        [Max fanout], [188],
        [Total fanout], [4406],
        [Ave fanout], [3.07],
      ),
    )<resource2_>],
    [#figure(
      caption: "課題2の最大動作周波数(@1.1V, 0℃)",
      table(
        columns: 2,
        table.header([], [2]),
        [CLK], [33.54 MHz],
      ),
    )<freq2>],
  )
]


== 課題3 (VGAによる画面表示)

#slide[
  - 3-1: 座標に応じてRGBを変化させて模様を表示する
  - 3-2: てきとうな図形(円)の描画
  - 3-3: ASCIIコードを用いた文字の描画

  #grid(
    columns: 3,
    gutter: 2cm,
    [#figure(
      caption: "3-1の表示",
      image("img/IMG_7952.jpg", height: 50mm),
    )],
    [#figure(
      caption: "3-2の表示",
      image("img/IMG_7957.jpg", height: 50mm),
    )],
    [#figure(
      caption: "3-3の表示",
      image("img/IMG_7956.jpg", height: 50mm),
    )],
  )

]

== 課題3 (VGAによる画面表示)

#slide[
  - ALUは課題2ほど使っていないが、メモリとPLLを使用した
  #grid(
    columns: 2,
    gutter: 2cm,
    [#figure(
      caption: "課題3の使用リソース",
      table(
        columns: 4,
        table.header([], [3-1], [3-2], [3-3]),
        [Logic usage], [118], [214], [220],
        [ALUT usage], [190], [360], [359],
        [Dedicated logic reg], [95], [213], [247],
        [IO pins], [96], [96], [96],
        [Total block memory bits],
        [#text(fill: red)[589824]],
        [#text(fill: red)[589824]],
        [#text(fill: red)[610304]],

        [Total PLLs],
        [#text(fill: red)[1]],
        [#text(fill: red)[1]],
        [#text(fill: red)[1]],

        // [Max fanout node], [AUD_BCLK~input], [AUD_BCLK~input],
        [Max fanout], [157], [275], [325],
        [Total fanout], [3207], [4298], [4732],
        [Ave fanout], [5.83], [5.13], [5.33],
      ),
    )<resource3_>],
    [#figure(
      caption: "課題3の最大動作周波数(@1.1V, 0℃)",
      table(
        columns: 4,
        table.header([], [3-1], [3-2], [3-3]),
        [pll divclk], [125.42 MHz], [75.57 MHz], [108.33 MHz],
        [oVGA_HS], [209.12 MHz], [188.93 MHz], [193.39 MHz],
      ),
    )<freq3>],
  )
]

== 課題4 (音声入出力)

#slide[
  - 4-1: 入力された音声をそのまま出力
  - 4-2: 周波数を設定して正弦波を出力
]


== 課題4 (音声入出力)

#slide[
  - メモリ使用量が3同様大きく、4-1ではfanoutも他と比べ大きい
  #grid(
    columns: 2,
    gutter: 2cm,
    [#figure(
      caption: "課題4の使用リソース",
      table(
        columns: 3,
        table.header([], [4-1], [4-2]),
        [Logic usage], [224], [162],
        [ALUT usage], [314], [262],
        [Dedicated logic reg], [253], [178],
        [IO pins], [106], [106],
        [Total block memory bits],
        [#text(fill: red)[2097152]],
        [#text(fill: red)[196608]],

        // [Max fanout node], [AUD_BCLK~input], [AUD_BCLK~input],
        [Max fanout], [432], [125],
        [Total fanout], [9723], [2007],
        [Ave fanout], [9.36], [2.95],
      ),
    )<resource4_>],
    [#figure(
      caption: "課題4の最大動作周波数(@1.1V, 0℃)",
      table(
        columns: 3,
        table.header([], [4-1], [4-2]),
        [AUD_BCLK], [185.36 MHz], [160.82 MHz],
        [CLOCK_500], [197.71 MHz], [186.15 MHz],
        [CLOCK_50], [274.65 MHz], [287.19 MHz],
        [I2C], [343.41 MHz], [418.76 MHz],
      ),
    )<freq4>],
  )
]
== 課題5

#slide[
  コンセプト: 格子ボルツマン法による流体シミュレーション
  - 簡単な離散的モデルで、流体中の粒子の運動を逐次計算する
  - 結果をVGAで(できればリアルタイムに)表示する
  #figure(
    caption: [完成イメージ(@cornell より引用)],
    image("img/laminar.png", height: 55mm),
  )<lbm_image>]

== 課題5(格子ボルツマン法のアルゴリズムの概要)

#slide[
  - 流体は粒子の集合で、2次元の離散的な格子上に分布するモデル
  - 次の時刻に隣接する格子に移動するか静止(物体に衝突した粒子は180°反射する)
  - このモデルのもとで、各時刻での粒子の密度や速度分布を更新
  #figure(
    caption: [格子ボルツマン法の流れ(@lbm_python より引用)],
    grid(
      columns: 2,
      gutter: 0cm,
      [#figure(
        image("img/lbm3.png", height: 40mm),
      )<lbm1>],
      [#figure(
        image("img/lbm4.png", height: 40mm),
      )<lbm2>],
    ),
  )
]


== 課題5(アーキテクチャ(？)案)

#slide[
  #figure(
    caption: [アーキテクチャ],
    image("img/arch2.jpg", height: 100mm),
  )<lbm1>
]


== 課題5(FPGAでの実装の利点#footnote([実際にFPGAでの高速化が報告されている @kenyon2007parcfd]))

#slide[
  - 各格子点で独立に流入してくる粒子の情報を処理すればよいため、並列計算に向いている
  - 複雑な制御フローがない
  - メモリアクセスが規則的かつ局所的である
]

#slide[
  #set text(size: 15pt)
  #bibliography("refs.bib")
]
