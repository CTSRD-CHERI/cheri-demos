open HolKernel boolLib bossLib
open blastLib

val () = new_theory "bounds"

val () = wordsLib.mk_word_size 32
val () = wordsLib.mk_word_size 35

(* --------------------------------------------------------------------------
   Definitions
   -------------------------------------------------------------------------- *)

(* Decode address and representable bounds bits
   to give full representable top "r_t" and representable bottom "r_b",
   Here "E" is an exponent, "a" is a pointer and "r" encodes
   the representable bounds.
*)

val full_bounds_def = Define`
  full_bounds (E : num) (a : word32) (r_tip : word3) =
  let a_top = (31 >< E + 9) a : word32
  and a_tip = (E + 8 >< E + 6) a
  and r_mid = ((w2w r_tip) : word9) << 6
  in
  let adjust = if (a_tip <+ r_tip) then -1w else 0w
  and r_bot = (w2w r_mid) << E
  in
  let r_b = ((a_top + adjust) << (E + 9)) + r_bot
  in
  r_b`

val inside_rep_bounds_def = Define`
  inside_rep_bounds (E : num) (a : word32) (r_tip : word3) (i : word32) =
  let a_mid = (E + 8 >< E) a : word9
  and i_mid = (E + 8 >< E) i
  and r_mid = ((w2w r_tip) : word9) << 6
  and s : word35 = 1w << (E + 9)
  (*and topBits : word32 = (i >> (E+32n))*)
  in
  let in_limits = if 0w <= i then i_mid <+ (r_mid - a_mid - 1w)
                             else (i_mid >=+ (r_mid - a_mid)) /\ (r_mid <> a_mid)
  (*and abs_val_lt_s : bool = ((topBits = -1w) \/ (topBits = 0w))*) (*((topBits #>> 1) ?? topBits) = 0w*)
  in
  (E >= 23) \/ ((w2w (word_abs (i))) <+ s) /\ in_limits`

(* --------------------------------------------------------------------------
   Definitions
   -------------------------------------------------------------------------- *)

val lem = Q.prove(
  `(MIN 31 (E + 39) = 31) /\ (MIN (E + 39) 31 = 31) /\
   (MIN 31 (32 + (E + 9) - 1) = 31) /\
   (MIN (31 + (E + 9)) 31 = 31)
  `,
  rw [arithmeticTheory.MIN_DEF])

val lt4 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 4n``
val lt26 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 26n``
val lt24 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 24n``
val lt23 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 23n``
val counter = ref 0

(*
val state = ref (([], T) : term list * term)
fun save_state x = (state := x; ALL_TAC x)
*)

local
   val () = set_trace "print blast counterexamples" 0
   val () = set_trace "print blast counterexamples" 1
   val ERR = mk_HOL_ERR "custom_bblast_prov_tac"
   val vname = fst o Term.dest_var
   fun fnd (s : (term, term) Term.subst) x =
     #residue (Option.valOf (List.find (fn {redex, ...} => vname redex = x) s))
   fun print_eq (name, t) =
     ( print ("\n" ^ StringCvt.padLeft #" " 12 name ^ " = ")
     ; Hol_pp.print_term t
     )
   (*val eval = boolSyntax.rhs o Thm.concl o EVAL
   val strip_eval = pairSyntax.strip_pair o eval
   fun subst_eval s = eval o Term.subst s
   fun encode t b = strip_eval ``encode ^t ^b``
   fun decode a [E, t_cc, b_c, l_7] =
         strip_eval ``decode ^E ^t_cc ^b_c ^a ^l_7``
     | decode _ _ = raise ERR "decode" ""
   fun strip_lets a tm =
     case Lib.total ((Term.dest_abs ## Lib.I) o boolSyntax.dest_let) tm of
        SOME ((v, tm'), b) => strip_lets ((v, b) :: a) tm'
      | NONE => List.rev a
   val decode_tms =
     decode_def
     |> Thm.concl
     |> boolSyntax.strip_forall
     |> snd
     |> boolSyntax.rhs
     |> strip_lets []
   val extra_decode_tms =
     [("adj t_c", ``adjustment a_mid r t_c : word33``),
      ("adj b_c", ``adjustment a_mid r b_c : word32``),
      ("len (t - b)", ``t - b : word32``)]
   val dec_tms = [``t_d: word33``, ``b_d: word32``]
   val enc_tms = [``E: num``, ``t_cc: word7``, ``b_c: word9``, ``l_7: word1``]
   val vcs =
     [("vc1", ``w2w (t: word32) <=+ t_d : word33``),
      ("vc2", ``t_d - (w2w (t : word32) : word33) <=+ ((1w : word33) << (E+2))``),
      ("vc3", ``((b_d : word32) <=+ b) : bool``),
      ("vc4", ``b - (b_d: word32) <+ (1w : word32) << (E+2)``)]*)
in
(* val ss = ref ([] : (term, term) Term.subst) *)
   fun custom_bblast_prove_tac (goal as (asl, g)) =
     (print "."; blastLib.BBLAST_PROVE_TAC goal)
     handle HolSatLib.SAT_cex ctm =>
       let
         val c = boolSyntax.lhs (Thm.concl ctm)
         val s = fst (Term.match_term g c)
         val fnd = fnd s
         (*val e = fnd "E"*)
         val a = fnd "a"
         val r = fnd "r"
         val i = fnd "i"
         (*val enc = encode t b
         val dec = decode a enc
         val s = List.map (op |->) (ListPair.zip (enc_tms, enc)) @ s
         val s = List.map (op |->) (ListPair.zip (dec_tms, dec)) @ s*)
       in
         print "\nCounterexample:\n"
       ; List.app print_eq [(*("E", e),*) ("a", a), ("r", r), ("i", i)]
       ; print "\nFailed subgoal:\n"
       ; Hol_pp.print_term c
       ; print "\n"
       (*; List.app print_eq (ListPair.zip (["E", "t_cc", "b_c", "l_7"], enc))
       ; print "\n"
       ; List.app print_eq (ListPair.zip (["t_d", "b_d"], dec))
       ; print "\n"
       ; let
           val s =
             List.foldl
             (fn ((v, t), s) =>
                let
                  val t' = subst_eval s t
                in
                  print_eq (vname v, t')
                ; (v |-> t') :: s
                end) s decode_tms*)
(* for debug: val () = ss := s *)
       (*    val pr = List.app (fn (name, tm) => print_eq (name, subst_eval s tm))
         in
           print "\n"
         ; pr extra_decode_tms
         ; print "\n"
         ; pr vcs
         end
       ; print "\n"*)
       ; raise ERR "custom_bblast_prove_tac" "found counterexample"
       end
end

val proof = Q.store_thm("proof_safe",
  `!E a r i.
     E < 26 ==>
     let
       r_b = full_bounds E a r;
       p = a + i;
       diff : word35 = w2w(p-r_b);
       s : word35 = (1w << (E + 9))
     in inside_rep_bounds E a r i ==>
       diff <+ s`,
  (fn x => (counter := 8*26; ALL_TAC x))
  \\simp_tac (srw_ss()++wordsLib.WORD_EXTRACT_ss++boolSimps.LET_ss)
       [full_bounds_def, inside_rep_bounds_def, wordsTheory.word_abs_def,
        wordsTheory.WORD_LEFT_ADD_DISTRIB, lem,
        wordsLib.WORD_DECIDE ``0w <= i = ~(i < 0w : 'a word)``]
  \\ ntac 5 strip_tac
  \\ Cases_on `((E + 8 >< E + 6) a) <+ r`
  \\ Cases_on `i < 0w`
  \\ Cases_on `-1w * r + ((E + 8 >< E + 6) a) < 0w`
  \\ asm_simp_tac std_ss []
  \\ blastLib.MP_BLASTABLE_TAC
  \\ simp [GSYM wordsTheory.word_msb_neg]
  \\ REVERSE (full_simp_tac std_ss [lt26])
  \\ simp []
  \\ (fn x => ( print (Int.toString (!counter) ^ "\n")
              ; Portable.dec counter
              ; ((* save_state \\ *) custom_bblast_prove_tac) x
              ))
  )

(* This one only looks at less than 23 because there is a case where the whole
address space is representable where a positive value can wrap the address space
and end up in bounds where the fast representable check says that it is out of
bounds (over the top).  I suppose it is a bit odd that this doesn't work, but
at least our behaviour is conservative. 
((p >> E) - (w2w(r_b) >> E))
*)

val proof = Q.store_thm("proof_useful",
  `!E a r i.
    E < 26 ==>
    let
      r_b = full_bounds E a r;
      p : word32 = w2w(a) + w2w(i);
      diff = (p >>> E) - (r_b >>> E)
    in ((diff >=+ 1w) /\ (diff <+ 511w)) ==>
      inside_rep_bounds E a r i`,
  (fn x => (counter := 8 * 26; ALL_TAC x))
  \\ simp_tac (srw_ss()++wordsLib.WORD_EXTRACT_ss++boolSimps.LET_ss)
       [full_bounds_def, inside_rep_bounds_def, wordsTheory.word_abs_def,
        wordsTheory.WORD_LEFT_ADD_DISTRIB, lem,
        wordsLib.WORD_DECIDE ``0w <= i = ~(i < 0w : 'a word)``]
  \\ ntac 5 strip_tac
  \\ Cases_on `(E + 8 >< E + 6) a <+ r`
  \\ Cases_on `i < 0w`
  \\ Cases_on `-1w * r + (E + 8 >< E + 6) a < 0w`
  \\ asm_simp_tac std_ss []
  \\ blastLib.MP_BLASTABLE_TAC
  \\ simp [GSYM wordsTheory.word_msb_neg]
  \\ REVERSE (full_simp_tac std_ss [lt26])
  \\ simp []
  \\ (fn x => ( print (Int.toString (!counter) ^ "\n")
              ; Portable.dec counter
              ; ((* save_state \\ *) custom_bblast_prove_tac) x
              ))
  )

(*
!state

EVAL ``let E = 1
       and a = 0xFFFF4C00w
       and i = 0x0w
       and r = 0x1w
       in
       let r_b = full_bounds E a r
       and p = a + i
       in
       (r_b, p, r_b <= p, inside_rep_bounds E a r i)``
*)

val () = export_theory()
