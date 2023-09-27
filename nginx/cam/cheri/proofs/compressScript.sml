(* -------------------------------------------------------------------------
   Santity checking proofs for compressed capabilities (CHERI-128).
   ------------------------------------------------------------------------- *)

open HolKernel boolLib bossLib
open blastLib

val () = new_theory "compress"

val () = wordsLib.mk_word_size 33
val () = wordsLib.guess_lengths()

(* -------------------------------------------------------------------------
   Definitions
   ------------------------------------------------------------------------- *)

val HighestSetBit_def = Define`
  HighestSetBit w = if w = 0w then 0w else word_log2 w`

(* Computes exponent "E" for top bound "t" and bottom bound "b". *)
val compute_E_def = Define`
  compute_E (t : word32) (b : word32) =
  let x = w2w (t - b) : word33 in w2n (HighestSetBit (x >>> 8))`

(* Computes "E" and compressed bounds "t_c" and "b_c". *)
val encode_def = Define`
  encode t b =
  let E = compute_E t b in
  let e (v : word32) = (E + 8n >< E) v : word9 in
  (
		E,
		(if E = 0 then 
		  (6 >< 0) (e t)
		else
		  ((6 >< 2) (e t) + (if (E + 1 >< 0) t = 0w : word32 then 0w else 1w)) << 2
		) : word7
		,
		(if E = 0 then 
		  (8 >< 0) (e b)
		else
		  ((8 >< 2) (e b)) << 2
		) : word9
		,
		((7 >< 7) ((t - b) >> E)) : word1
  )`

(* Helper function. *)
val adjustment_def = Define`
  adjustment (a_mid : word9) r c =
  (if a_mid <+ r then -1w else 0w) + (if c <+ r then 1w else 0w)`

(* Decodes compressed bounds for pointer addres "a". *)
val decode_def = Define`
  decode (E : num) (t_cc : word7) (b_c : word9) (a : word32) (l_7 : word1) =
  let (carry_out : word2)  = if ((6 >< 2) t_cc <+ ((6 >< 2) b_c : word5)) then 1w else 0w
  and (length_msb : word2) = if E = 0 then 1w else w2w l_7 in
  let (t_tip : word2)  = ((8 >< 7) b_c) + carry_out + length_msb in
  let (t_c   : word9)  = (w2w t_cc) || ((w2w t_tip) << 6)
  and (a_top : word32) = (31 >< E + 9) a
  and (a_mid : word9)  = (E + 8 >< E) a
  and (r     : word9)  = b_c - (64w : word9) in
  ((a_top + (((adjustment a_mid r t_c) : word32) << (E + 9)) || ((w2w t_c) << E)),
   (a_top + (((adjustment a_mid r b_c) : word32) << (E + 9)) || ((w2w b_c) << E)))`

(* -------------------------------------------------------------------------
   Proofs
   ------------------------------------------------------------------------- *)

val word_log2_33 =
  wordsTheory.LOG2_w2n_lt
  |> Q.INST_TYPE [`:'a` |-> `:33`]
  |> SIMP_RULE (srw_ss()) []

val E_bound_lem = Q.prove(
  `!t b. compute_E t b < 26`,
  rw [compute_E_def, HighestSetBit_def, wordsTheory.word_log2_def]
  \\ imp_res_tac word_log2_33
  \\ simp [arithmeticTheory.LESS_MOD]
  \\ rule_assum_tac (REWRITE_RULE [GSYM wordsTheory.w2n_eq_0])
  \\ simp [bitTheory.LT_TWOEXP
           |> Drule.SPEC_ALL
           |> Q.DISCH `x <> 0`
           |> SIMP_RULE std_ss []
           |> GSYM]
  \\ wordsLib.n2w_INTRO_TAC 33
  \\ qabbrev_tac `x = -1w * b + t`
  \\ blastLib.BBLAST_PROVE_TAC
  )

val log2_expand_thm = Q.store_thm("log2_expand_thm",
  `!w: 'a word n.
      w <> 0w /\ n < dimindex(:'a) ==>
      ((word_log2 w = n2w n) =
       w ' n /\ (!i. n < i /\ i < dimindex(:'a) ==> ~w ' i))`,
  rw [wordsTheory.word_log2_def]
  \\ `(dimindex (:'a) - 1n - LEAST i. (w:'a word) ' (dimindex (:'a) - 1 - i)) <
      dimindex (:'a)` by decide_tac
  \\ `n < dimword(:'a) /\
      (dimindex (:'a) - 1n - LEAST i. (w:'a word) ' (dimindex (:'a) - 1 - i)) <
      dimword(:'a)`
  by metis_tac [wordsTheory.dimindex_lt_dimword, arithmeticTheory.LESS_TRANS]
  \\ asm_simp_tac std_ss
       [wordsTheory.LOG2_w2n, arithmeticTheory.LESS_MOD,
        wordsTheory.dimindex_lt_dimword]
  \\ numLib.LEAST_ELIM_TAC
  \\ rw []
  >- (imp_res_tac wordsTheory.NOT_0w
      \\ qexists_tac `dimindex(:'a) - i - 1`
      \\ simp [])
  \\ eq_tac
  \\ rw []
  \\ simp []
  >- (`dimindex(:'a) - i - 1 < n'` by decide_tac
      \\ qpat_x_assum `!m. P` imp_res_tac
      \\ rfs [])
  \\ CCONTR_TAC
  \\ `dimindex (:'a) - (n' + 1) < n \/ n < dimindex (:'a) - (n' + 1)`
  by decide_tac
  >- (`dimindex (:'a) - n - 1 < n'` by decide_tac
      \\ qpat_x_assum `!m. m < p' ==> ~w ' (dimindex (:'a) - (m + 1))`
           imp_res_tac
      \\ rfs [])
  \\ `dimindex(:'a) - (n' + 1) < dimindex(:'a)` by decide_tac
  \\ metis_tac []
  )

val WORD_LESS_THM = Q.prove(
  `!a n. SUC n < dimword(:'a) ==>
         (a <+ n2w (SUC n) : 'a word = (a = n2w n) \/ a <+ n2w n)`,
  Cases \\ simp [wordsTheory.word_lo_n2w, arithmeticTheory.LESS_MOD])

fun WORD_LESS_CONV tm =
  let
    val (l, r) = wordsSyntax.dest_word_lo tm
    val (r, ty) = wordsSyntax.dest_n2w r
    val th1 = Conv.REPEATC (Conv.DEPTH_CONV numLib.num_CONV) r
    val th2 = WORD_LESS_THM |> Drule.ISPEC l
                            |> CONV_RULE (Conv.DEPTH_CONV wordsLib.SIZES_CONV)
  in
    (ONCE_REWRITE_CONV [th1]
     THENC SIMP_CONV std_ss [th2, wordsTheory.WORD_LO_word_0]) tm
  end

val EXPAND_RANGE_TAC =
  qpat_assum `!i. xxx < i /\ i < yyy : num ==> P`
    (fn th =>
       let
         val (t1, t2) =
           th |> Thm.concl
              |> boolSyntax.dest_forall |> snd
              |> boolSyntax.dest_imp_only |> fst
              |> boolSyntax.dest_conj
         val lo = t1 |> numSyntax.dest_less |> fst |> numLib.int_of_term
         val hi = t2 |> numSyntax.dest_less |> snd |> numLib.int_of_term
       in
         print ("\n from " ^ Int.toString (lo + 1) ^ " to " ^
                             Int.toString (hi - 1) ^ "\n") ;
         MAP_EVERY (assume_tac o SIMP_RULE std_ss [])
           (Lib.for (lo + 1) (hi - 1)
              (fn i => Thm.SPEC (numLib.term_of_int i) th))
       end
    )

(* What is E_big_enough? *)
val E_big_enough = Count.apply Q.store_thm("E_big_enough",
  `!t b. (w2w (t - b) : word33) <+ n2w (2 ** 9) << compute_E t b`,
  REPEAT strip_tac
  \\ qspecl_then [`t`, `b`] mp_tac E_bound_lem
  \\ qabbrev_tac `x = -1w * b + t`
  \\ simp [compute_E_def]
  \\ pop_assum kall_tac
  \\ Cases_on `(w2w x >>> 8) = 0w : word33`
  >- (simp [HighestSetBit_def] \\ blastLib.FULL_BBLAST_TAC)
  \\ strip_tac
  \\ rfs [HighestSetBit_def,
          wordsTheory.WORD_LO
          |> Q.SPECL [`x`, `26w`]
          |> Q.INST_TYPE [`:'a` |-> `:33`]
          |> SIMP_RULE (srw_ss()) []
          |> GSYM]
  \\ rule_assum_tac (CONV_RULE (TRY_CONV WORD_LESS_CONV))
  \\ rfs []
  \\ rev_full_simp_tac (std_ss++wordsLib.SIZES_ss)
           [log2_expand_thm
            |> Q.INST_TYPE [`:'a` |-> `:33`]
            |> SIMP_RULE (srw_ss()) []]
  \\ (EXPAND_RANGE_TAC
      \\ blastLib.MP_BLASTABLE_TAC
      \\ blastLib.BBLAST_PROVE_TAC)
  )

val lt26 = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM] ``x < 26n``

(* There are lots of cases, so we monitor progress with a counter. *)
val counter = ref 0

val proof1 = Count.apply Q.prove(
  `!a t b. let (E, t_cc, b_c, l_7) = encode t b in
           let (t_d, b_d) = decode E t_cc b_c a l_7 in
           b <=+ a - n2w (2 ** 6) << E /\
           a <=+ t + n2w (2 ** 6 - 1) << E ==>
           (w2w t <=+ t_d /\ t_d - w2w t <=+ 1w << E) /\
           (b_d <=+ b /\ (w2w b - w2w b_d : word33) <+ 1w << E)`,
  (fn x => (counter := 12 * 26; ALL_TAC x))
  (* (fn x => (counter := 12 * 3; ALL_TAC x)) *)
  \\ REPEAT strip_tac
  \\ simp [encode_def]
  \\ qabbrev_tac `E = compute_E t b`
  \\ `E < 26` by metis_tac [E_bound_lem]
  \\ `(w2w (t - b) : word33) <=+ n2w (2 ** 9) << E`
  by (simp [] \\ metis_tac [SIMP_RULE (srw_ss()) [] E_big_enough])
  \\ simp [decode_def, adjustment_def]
  \\ strip_tac
  \\ Cases_on `(E + 8 >< E) a <+ (E + 8 >< E) b - 0x040w : word9`
  \\ (
      conj_tac
      >| [
          Cases_on `(E − 1 >< 0) t = 0w : word32`
          >| [
              Cases_on `(E + 8 >< E) t <+ (E + 8 >< E) b - 0x040w : word9`,
              Cases_on `w2w ((E + 8 >< E) t + 1w : word9) <+
                        (E + 8 >< E) b - 0x040w : word9`
             ],
          Cases_on `(E + 8 >< E) b <+ (E + 8 >< E) b - 0x040w : word9`
         ])
  \\ simp []
  \\ blastLib.MP_BLASTABLE_TAC
  \\ full_simp_tac std_ss [lt26]
  (* \\ `(E = 25) \/ (E = 0) \/ (E = 9)` by cheat
     \\ full_simp_tac std_ss [] *)
  \\ simp_tac (srw_ss()++wordsLib.WORD_EXTRACT_ss) []
  \\ (fn x => ( print (Int.toString (!counter) ^ "\n")
              ; Portable.dec counter
              ; blastLib.BBLAST_PROVE_TAC x))
  )

(*
  EVAL ``let a = 0x405C102022800000w
         and t = 0x405C105F5D769044w
         and b = 0x39FDFEF728071000w
         in let (E, t_c, b_c) = encode t b in
         let (t_d, b_d) = decode E t_c b_c a in
         (E, t_d, b_d,
          w2w t <=+ t_d, t_d - w2w t <=+ 1w << E,
          b_d <=+ b, (w2w b - w2w b_d : word33) <+ 1w << E)``
*)

val () = export_theory()
