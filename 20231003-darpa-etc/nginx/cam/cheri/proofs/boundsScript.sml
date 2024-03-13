open HolKernel boolLib bossLib
open blastLib

val () = new_theory "bounds"

val () = wordsLib.mk_word_size 33

(* --------------------------------------------------------------------------
   Definitions
   -------------------------------------------------------------------------- *)

(* Decode address and representable bounds bits
   to give full representable top "r_t" and representable bottom "r_b",
   Here "E" is an exponent, "a" is a pointer and "r" encodes
   the representable bounds.
*)

val full_bounds_def = Define`
  full_bounds (E : num) (a : word32) (r : word9) =
  let a_top = (31 >< E + 9) a : word32
  and a_mid = (E + 8 >< E) a
  in
  let adjust = if a_mid <+ r then -1w else 0w
  and r_bot = w2w r << E
  in
  let r_t = (a_top + adjust + 1w) << (E + 9) + r_bot
  and r_b = (a_top + adjust) << (E + 9) + r_bot
  in
  (r_t, r_b)`

val inside_rep_bounds_def = Define`
  inside_rep_bounds (E : num) (a : word32) (r : word9) (i : word32) =
  let a_mid = (E + 8 >< E) a : word9
  and i_mid = (E + 8 >< E) i
  and s = (1w : word32) << (9 + E)
  in
  let in_limits = if 0w <= i then i_mid <+ (r - a_mid - 1w)
                             else i_mid >=+ (r - a_mid) /\ r <> a_mid
  in
  E >= 24 \/ word_abs i <+ s /\ in_limits`

(* --------------------------------------------------------------------------
   Definitions
   -------------------------------------------------------------------------- *)

val lem = Q.prove(
  `(MIN 31 (E + 39) = 31) /\ (MIN (E + 39) 31 = 31) /\
   (MIN 31 (32 + (E + 9) - 1) = 31) /\
   (MIN (31 + (E + 9)) 31 = 31)
  `,
  rw [arithmeticTheory.MIN_DEF])

val lt46 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 4n``
val lt46 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 26n``
val counter = ref 0

(*
val state = ref (([], T) : term list * term)
fun save_state x = (state := x; ALL_TAC x)
*)

val proof = Q.store_thm("proof",
  `!E a r i.
     E < 26 ==>
     let (r_t, r_b) = full_bounds E a r in
     r_b <=+ a /\ a <+ r_t /\ inside_rep_bounds E a r i ==>
     let p = a + i in r_b <=+ p /\ p <+ r_t`,
  (fn x => (counter := 8 * 26; ALL_TAC x))
  \\ simp_tac (srw_ss()++wordsLib.WORD_EXTRACT_ss++boolSimps.LET_ss)
       [full_bounds_def, inside_rep_bounds_def, wordsTheory.word_abs_def,
        wordsTheory.WORD_LEFT_ADD_DISTRIB, lem,
        wordsLib.WORD_DECIDE ``0w <= i = ~(i < 0w : 'a word)``]
  \\ ntac 5 strip_tac
  \\ Cases_on `(E + 8 >< E) a <+ r`
  \\ Cases_on `i < 0w`
  \\ Cases_on `-1w * r + (E + 8 >< E) a < 0w`
  \\ asm_simp_tac std_ss []
  \\ blastLib.MP_BLASTABLE_TAC
  \\ simp [GSYM wordsTheory.word_msb_neg]
  \\ REVERSE (full_simp_tac std_ss [lt46])
  \\ simp []
  \\ (fn x => ( print (Int.toString (!counter) ^ "\n")
              ; Portable.dec counter
              ; ((* save_state \\ *) blastLib.BBLAST_PROVE_TAC) x
              ))
  )

(*
!state

EVAL ``let E = 3
       and a = 0x1007FF893010w
       and i = 0xFFFFFFFFFFFB27F5w
       and r = 0x12602w
       in
       let (r_t, r_b) = full_bounds E a r
       and p = a + i
       in
       (r_b, r_t, p, r_b <= p, p < r_t, inside_rep_bounds E a r i)``

*)

val () = export_theory()
