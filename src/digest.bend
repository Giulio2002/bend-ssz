import Base
import 0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend as PKG

# A 32-byte SSZ chunk held as eight big-endian words instead of thirty-two
# list cells, and the single hashing primitive SSZ merkleization needs.
#
# Hashing goes through the pinned BendHub package
# `0xda83506fb9f059ead7afcfa2f498df5f` (Giulio2002/bend-sha256), whose sole
# production entry point takes a packed `Array<U32>` and a byte length and
# returns eight packed words. Nothing on this path builds, walks or consumes a
# linked list: the sixteen input words are written into a sixteen-slot array
# by index and the eight result words are read out of the array the package
# returns by index.
#
# `bytes` is the byte-list *view* of a chunk. It exists for the specifications
# and their proofs only; no runtime path calls it.
type Digest is Data:
  D{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32}

# The message array for one Merkle node: left chunk then right chunk, four
# big-endian bytes per word, sixteen words = the 64-byte message. It is built
# by `Array.new` and sixteen `Array.set`s and the result is read back by eight
# `Array.get`s. Building it from nested `ANode` constructors, or reading the
# result by matching its `ANode` shape, gives the same words but costs a block
# copy per node on the native runtime; the indexed form is 32 % faster per hash
# (benchmarks/probes/hash_variants.bend: 52 ms against 76 ms for 200,000 chained
# nodes, same final digest).
def set16(a: Array<U32>, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32,
          +b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
    a, 0, a0), 1, a1), 2, a2), 3, a3), 4, a4), 5, a5), 6, a6), 7, a7),
    8, b0), 9, b1), 10, b2), 11, b3), 12, b4), 13, b5), 14, b6), 15, b7)

def pair_words(l: Digest, r: Digest) -> Array<U32>:
  match l:
    case D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match r:
        case D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          set16(Array.new(U32, 4n, 0), a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7)

# The package returns eight words; they are read by index, one definition per
# word because Bend cannot match a computed pair.
def g7(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w7) = pair
  D{w0, w1, w2, w3, w4, w5, w6, w7}

def g6(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w6) = pair
  g7(w0, w1, w2, w3, w4, w5, w6, Array.get(U32, a, 7))

def g5(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w5) = pair
  g6(w0, w1, w2, w3, w4, w5, Array.get(U32, a, 6))

def g4(+w0: U32, +w1: U32, +w2: U32, +w3: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w4) = pair
  g5(w0, w1, w2, w3, w4, Array.get(U32, a, 5))

def g3(+w0: U32, +w1: U32, +w2: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w3) = pair
  g4(w0, w1, w2, w3, Array.get(U32, a, 4))

def g2(+w0: U32, +w1: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w2) = pair
  g3(w0, w1, w2, Array.get(U32, a, 3))

def g1(+w0: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w1) = pair
  g2(w0, w1, Array.get(U32, a, 2))

def g0(pair: Array<U32> & U32) -> Digest:
  (a, +w0) = pair
  g1(w0, Array.get(U32, a, 1))

def of_array(a: Array<U32>) -> Digest: g0(Array.get(U32, a, 0))

# `None` is the package's answer for an oversized byte length; a 64-byte
# message never is one.
def of_result(r: Maybe<&1, Array<U32>>) -> Digest:
  match r:
    case None{}: D{0, 0, 0, 0, 0, 0, 0, 0}
    case Some{a}: of_array(a)

# One Merkle node: SHA-256 of the two chunks concatenated, 64 bytes in,
# 32 bytes out, no intermediate list anywhere. The root code passes the
# message length `hl` (always 64) down as a parameter instead of writing the
# literal at every node, so that laws about whole roots can keep it abstract:
# with a symbolic length the package's SHA-256 does not unfold in a proof,
# while every root law is instantiated at 64 exactly where the public
# `*_hash_tree_root` entry points pass it (proofs/obj/sha_node.bend).
def node(+hl: Nat, l: Digest, r: Digest) -> Digest:
  of_result(PKG.sha256(pair_words(l, r), hl))

def hash_pair(l: Digest, r: Digest) -> Digest: node(64n, l, r)

def zero() -> Digest: D{0, 0, 0, 0, 0, 0, 0, 0}

# The zero-subtree roots Z(0) .. Z(63) of SSZ merkleization: Z(0) is the zero
# chunk and Z(k + 1) = SHA-256(Z(k) ++ Z(k)), as big-endian words. They are
# constants of SHA-256, like fastssz's zero-hash table, and are checked against
# the specification's zero_subtree by proofs/obj/zero_roots.bend (one concrete
# FIPS evaluation per level); a depth of 64 or more is never reached (the
# deepest Fulu limit is 2^40 elements, and no U32 chunk count needs more).
def zconst(+k: Nat) -> Digest:
  match k:
    case 0n: D{0, 0, 0, 0, 0, 0, 0, 0}
    case 1n+k1:
    match k1:
      case 0n: D{4121296194, 3513393200, 664334190, 3540621211, 1124089123, 551153896, 3935842729, 660208459}
      case 1n+k2:
      match k2:
        case 0n: D{3679850830, 16635073, 4166813995, 4082813352, 2458495724, 2985021609, 1826513002, 1955290481}
        case 1n+k3:
        match k3:
          case 0n: D{3347057149, 4034905450, 301015607, 106472275, 2862957293, 1675906123, 3244291277, 274379580}
          case 1n+k4:
          match k4:
            case 0n: D{1399691395, 2133709157, 2774359786, 3910436245, 1148376431, 611185238, 3208424985, 891949628}
            case 1n+k5:
            match k5:
              case 0n: D{2667438162, 2853520031, 2919611092, 3501316038, 1302744323, 3617686858, 1485581496, 1124863280}
              case 1n+k6:
              match k6:
                case 0n: D{3633176558, 3556812917, 1435939353, 1119963518, 290205742, 1628973327, 2447800105, 1979981729}
                case 1n+k7:
                match k7:
                  case 0n: D{2280328667, 2776511990, 3532023608, 44347225, 1977754886, 3352251492, 3144410606, 290619180}
                  case 1n+k8:
                  match k8:
                    case 0n: D{646210678, 4250912074, 1564686417, 1741246788, 4066656083, 1019763641, 3513481263, 2373824915}
                    case 1n+k9:
                    match k9:
                      case 0n: D{1349355096, 757408773, 3091202439, 2462765759, 307884527, 1520826503, 3778851568, 156193249}
                      case 1n+k10:
                      match k10:
                        case 0n: D{4294904535, 3864622895, 2503262613, 3356880836, 21950945, 3672982532, 3227747793, 294840619}
                        case 1n+k11:
                        match k11:
                          case 0n: D{1827684647, 3674555420, 3627225210, 1388217640, 1753812547, 400990250, 3027665834, 1972781600}
                          case 1n+k12:
                          match k12:
                            case 0n: D{3083886471, 1595146279, 4015069346, 612088708, 3465490191, 287531568, 2245719958, 204644191}
                            case 1n+k13:
                            match k13:
                              case 0n: D{3748328949, 3151719401, 4018841112, 3837755507, 2517133079, 506029935, 2334674410, 1778952286}
                              case 1n+k14:
                              match k14:
                                case 0n: D{3045953551, 1578643004, 1357870230, 2661379191, 650463605, 2093102371, 3278461053, 2804496260}
                                case 1n+k15:
                                match k15:
                                  case 0n: D{3566892290, 4291801140, 186480773, 1753546954, 813785511, 4184564447, 2634562417, 4241027771}
                                  case 1n+k16:
                                  match k16:
                                    case 0n: D{2414260584, 2455158995, 2247372635, 3189778338, 739874529, 280664001, 1909712276, 2380868587}
                                    case 1n+k17:
                                    match k17:
                                      case 0n: D{2366464963, 2663046789, 165719612, 2620946171, 1604391614, 418973164, 2902379410, 91620267}
                                      case 1n+k18:
                                      match k18:
                                        case 0n: D{2515454130, 3846294228, 3911050115, 2247286854, 1637831753, 1814266571, 1823266233, 2351363492}
                                        case 1n+k19:
                                        match k19:
                                          case 0n: D{4170443016, 2440525238, 738140969, 1304159137, 3448663233, 3277539329, 2289788010, 1870786943}
                                          case 1n+k20:
                                          match k20:
                                            case 0n: D{3453724597, 2464355123, 2478924180, 4207362842, 3207550085, 3983613362, 2182626433, 2651384746}
                                            case 1n+k21:
                                            match k21:
                                              case 0n: D{2324529123, 2945231368, 1517697448, 838866007, 3753448074, 2153845802, 3493025321, 4280549276}
                                              case 1n+k22:
                                              match k22:
                                                case 0n: D{4273193783, 3617921647, 3204495843, 1280500169, 425498267, 3571949759, 3575471195, 3986428263}
                                                case 1n+k23:
                                                match k23:
                                                  case 0n: D{3877571240, 1019424479, 3204095821, 1040282826, 2232954604, 2671380982, 2797657955, 2007306455}
                                                  case 1n+k24:
                                                  match k24:
                                                    case 0n: D{824209320, 173063018, 3190360144, 1492214290, 556425454, 3371190782, 3415398600, 3769125824}
                                                    case 1n+k25:
                                                    match k25:
                                                      case 0n: D{557132798, 3421363689, 2474876769, 1279110154, 1055094083, 4189328049, 1637473301, 2384704836}
                                                      case 1n+k26:
                                                      match k26:
                                                        case 0n: D{1637757223, 616263036, 827583901, 3885094756, 2741416841, 2937308555, 4171815172, 2175035237}
                                                        case 1n+k27:
                                                        match k27:
                                                          case 0n: D{2094868870, 646074466, 2366378211, 2244316257, 2447834080, 1368505536, 1326661420, 3933389252}
                                                          case 1n+k28:
                                                          match k28:
                                                            case 0n: D{2223583421, 2074659525, 1180763937, 335226760, 1776319416, 1484755257, 691222349, 24890337}
                                                            case 1n+k29:
                                                            match k29:
                                                              case 0n: D{2288647980, 582126785, 84990341, 848461875, 683560880, 3892614632, 3146589983, 1535678006}
                                                              case 1n+k30:
                                                              match k30:
                                                                case 0n: D{3053332711, 2669380879, 2253923436, 3921060327, 3030368365, 3071557263, 3769954992, 3310500444}
                                                                case 1n+k31:
                                                                match k31:
                                                                  case 0n: D{2556334751, 1890527440, 3184634122, 2156894079, 1501330551, 2353569432, 3552413968, 3541745911}
                                                                  case 1n+k32:
                                                                  match k32:
                                                                    case 0n: D{3338042882, 3873759677, 4021916870, 159994867, 1177991723, 1822558791, 567456362, 2288460543}
                                                                    case 1n+k33:
                                                                    match k33:
                                                                      case 0n: D{479886943, 4056893620, 2903868115, 4108624128, 1329275096, 3315775251, 2275681610, 3644058565}
                                                                      case 1n+k34:
                                                                      match k34:
                                                                        case 0n: D{789011170, 694446959, 1793923493, 3815952169, 1350647838, 3096706905, 2604636876, 202194557}
                                                                        case 1n+k35:
                                                                        match k35:
                                                                          case 0n: D{847847902, 3046511111, 1744955597, 1633231111, 3049684089, 3091618140, 3325168697, 1531328044}
                                                                          case 1n+k36:
                                                                          match k36:
                                                                            case 0n: D{3216574973, 2989927716, 297067656, 940613748, 3091220038, 2308467775, 2323681666, 2115486503}
                                                                            case 1n+k37:
                                                                            match k37:
                                                                              case 0n: D{1440283446, 2277129124, 2670996599, 4121032859, 3968063505, 1148066374, 1899569469, 1678469748}
                                                                              case 1n+k38:
                                                                              match k38:
                                                                                case 0n: D{4146138447, 2390626361, 2030992372, 4020373333, 1511040731, 500480349, 2735975080, 2341011062}
                                                                                case 1n+k39:
                                                                                match k39:
                                                                                  case 0n: D{2904667414, 3418768895, 3813324254, 478867340, 3571972306, 3038678548, 1454229334, 1020928111}
                                                                                  case 1n+k40:
                                                                                  match k40:
                                                                                    case 0n: D{1811844395, 3426891703, 1246775045, 2398377267, 2664264544, 3412311995, 2397389966, 1680914948}
                                                                                    case 1n+k41:
                                                                                    match k41:
                                                                                      case 0n: D{2817670377, 404177116, 571244871, 2187677678, 1791932913, 3969000132, 3796270346, 2976385079}
                                                                                      case 1n+k42:
                                                                                      match k42:
                                                                                        case 0n: D{2935572332, 2304313900, 2362028983, 1330210759, 1472503192, 1722043308, 4062159597, 1734205346}
                                                                                        case 1n+k43:
                                                                                        match k43:
                                                                                          case 0n: D{2588064941, 2197203428, 310695944, 3939703282, 2671446048, 2640842510, 753341712, 3497124357}
                                                                                          case 1n+k44:
                                                                                          match k44:
                                                                                            case 0n: D{3517345077, 1248311759, 395669976, 3858331538, 1903070676, 3963885928, 967047110, 3075443628}
                                                                                            case 1n+k45:
                                                                                            match k45:
                                                                                              case 0n: D{4210700325, 4076377353, 3267828852, 4221619602, 2240738459, 125893460, 2037673098, 2617029446}
                                                                                              case 1n+k46:
                                                                                              match k46:
                                                                                                case 0n: D{859088833, 3891687514, 2785090154, 2492876033, 1840557278, 212446166, 1841798530, 1715613782}
                                                                                                case 1n+k47:
                                                                                                match k47:
                                                                                                  case 0n: D{127335797, 1716498167, 1156468306, 3609665067, 3145113489, 3983514484, 3635844341, 1711703340}
                                                                                                  case 1n+k48:
                                                                                                  match k48:
                                                                                                    case 0n: D{2074324554, 1098901588, 1528048584, 2672483543, 2920518684, 3132585227, 2213146790, 1830207076}
                                                                                                    case 1n+k49:
                                                                                                    match k49:
                                                                                                      case 0n: D{2022682572, 1252335673, 2598088401, 2516103468, 1320361665, 23651594, 2881903014, 2930054876}
                                                                                                      case 1n+k50:
                                                                                                      match k50:
                                                                                                        case 0n: D{3895711654, 1902175883, 4106814538, 1392999922, 1920651276, 4084156745, 3350626729, 303303867}
                                                                                                        case 1n+k51:
                                                                                                        match k51:
                                                                                                          case 0n: D{815705072, 2514249492, 4193572964, 3148197882, 3769850594, 4125316699, 3426371506, 309753601}
                                                                                                          case 1n+k52:
                                                                                                          match k52:
                                                                                                            case 0n: D{577408702, 4196959845, 2789516546, 1932746491, 3054522639, 605772658, 210384525, 1504090717}
                                                                                                            case 1n+k53:
                                                                                                            match k53:
                                                                                                              case 0n: D{1101790617, 1411744374, 630423857, 2936819507, 4262188136, 2351049761, 4204636392, 2628387832}
                                                                                                              case 1n+k54:
                                                                                                              match k54:
                                                                                                                case 0n: D{1143759918, 4111442342, 1738991313, 96959580, 3288254679, 2854580431, 439383989, 63144041}
                                                                                                                case 1n+k55:
                                                                                                                match k55:
                                                                                                                  case 0n: D{2694876668, 2604849516, 769760109, 310086369, 920506174, 1523637476, 583293526, 4129254004}
                                                                                                                  case 1n+k56:
                                                                                                                  match k56:
                                                                                                                    case 0n: D{2100593538, 2936630718, 200312519, 3141120674, 3233560246, 564857971, 2392360407, 836245312}
                                                                                                                    case 1n+k57:
                                                                                                                    match k57:
                                                                                                                      case 0n: D{984691829, 488182377, 40666777, 1319799619, 2822458065, 4140885875, 2177163927, 1258014966}
                                                                                                                      case 1n+k58:
                                                                                                                      match k58:
                                                                                                                        case 0n: D{2591314529, 498258494, 2921789885, 3146290574, 4098647248, 4271406057, 4146507257, 955584364}
                                                                                                                        case 1n+k59:
                                                                                                                        match k59:
                                                                                                                          case 0n: D{1918664577, 1614266340, 1389174395, 2740634750, 3702823578, 724020938, 1893524611, 3414027551}
                                                                                                                          case 1n+k60:
                                                                                                                          match k60:
                                                                                                                            case 0n: D{753539829, 531794786, 2289842585, 2328493812, 3755923999, 132149690, 1435113274, 4245081027}
                                                                                                                            case 1n+k61:
                                                                                                                            match k61:
                                                                                                                              case 0n: D{4280113657, 2339132701, 2500367191, 92101771, 3798204967, 2661150897, 3743027383, 737383039}
                                                                                                                              case 1n+k62:
                                                                                                                              match k62:
                                                                                                                                case 0n: D{797579295, 2090458401, 1517627839, 3801524576, 974407283, 1904661018, 3951806382, 1507982625}
                                                                                                                                case 1n+k63:
                                                                                                                                match k63:
                                                                                                                                  case 0n: D{3972334281, 2970902329, 1355513150, 943866991, 2175070431, 502609870, 3778670436, 3935849433}
                                                                                                                                  case 1n+k64: zero()

# ---------------------------------------------------------------------------
# Specification-facing views. These are used by proofs and by test oracles,
# never by the measured runtime path.
def be_bytes(+x: U32, tail: +List<U32>) -> +List<U32>:
  (U32.shrn(x, 24n) .&. 255 : U32) <> ((U32.shrn(x, 16n) .&. 255 : U32) <> ((U32.shrn(x, 8n) .&. 255 : U32) <> ((x .&. 255 : U32) <> tail)))

def bytes_onto(d: Digest, tail: +List<U32>) -> +List<U32>:
  match d:
    case D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      be_bytes(w0, be_bytes(w1, be_bytes(w2, be_bytes(w3, be_bytes(w4, be_bytes(w5, be_bytes(w6, be_bytes(w7, tail))))))))

def bytes(d: Digest) -> +List<U32>: bytes_onto(d, [])

def equal(a: Digest, b: Digest) -> Bool:
  match a:
    case D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match b:
        case D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          Bool.and(U32.is_eq(a0, b0), Bool.and(U32.is_eq(a1, b1), Bool.and(U32.is_eq(a2, b2), Bool.and(U32.is_eq(a3, b3),
            Bool.and(U32.is_eq(a4, b4), Bool.and(U32.is_eq(a5, b5), Bool.and(U32.is_eq(a6, b6), U32.is_eq(a7, b7))))))))
