(* -------------------------------------------------------------------------
   Santity checking proofs for compressed capabilities (CHERI-128).
   ------------------------------------------------------------------------- *)

open HolKernel boolLib bossLib
open blastLib

val () = new_theory "compress"

val () = ( wordsLib.mk_word_size 33
         ; wordsLib.guess_lengths()
         );

(* -------------------------------------------------------------------------
   Definitions
   ------------------------------------------------------------------------- *)

val HighestSetBit_def = Define`
  HighestSetBit w = if w = 0w then 0w else word_log2 w`

(* Computes exponent "E" for top bound "t" and bottom bound "b". *)
val compute_E_def = Define`
  compute_E (t : word32) (b : word32) =
  let
    len = w2w (t - b) : word33;
    E_initial = w2n (HighestSetBit (len >>> 7));
    E_overflow =
      if (E_initial + 7 >< E_initial + 3) len = 0b11111w: word5 then 1n else 0n;
    E = if E_overflow = 1 then E_initial + 1 else E_initial;
  in
    (E, E_overflow)`

(* Computes "E" and compressed bounds "t_c" and "b_c". *)
val encode_def = Define`
  encode t_initial b =
  let
    (E, E_overflow) = compute_E t_initial b;
    (* This line adds 1 if we are forcing overflow to ensure that we round up
       later. *)
    t = if E_overflow = 1 then t_initial + 1w else t_initial;
    e (v : word32) = (E + 8n >< E) v : word9
  in
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
    ((7 >< 7) ((t - b) >>> E)) : word1
  )`

(* Helper function. *)
val adjustment_def = Define`
  adjustment (a_mid : word9) r c =
  (if a_mid <+ r then -1w else 0w) + (if c <+ r then 1w else 0w)`

(* Decodes compressed bounds for pointer addres "a". *)
val decode_def = Define`
  decode (E : num) (t_cc : word7) (b_c : word9) (a : word32) (l_7 : word1) =
  let
    carry_out =
      if ((6 >< 0) t_cc <+ (6 >< 0) b_c : word7) then 1w else 0w;
    length_msb : word2 = if E = 0 then w2w l_7 else 1w ;
    t_tip : word2  = (8 >< 7) b_c + carry_out + length_msb ;
    t_c   : word9  = w2w t_cc || w2w t_tip << 7 ;
    a_top : word32 = (31 >< E + 9) a ;
    a_mid : word9  = (E + 8 >< E) a ;
    r     : word9  = ((b_c - 64w) >> 6) << 6
  in
  ((w2w a_top + adjustment a_mid r t_c : word33) << (E + 9) || (w2w t_c) << E,
   (a_top + adjustment a_mid r b_c) << (E + 9) || (w2w b_c) << E)`

(* -------------------------------------------------------------------------
   Proofs
   ------------------------------------------------------------------------- *)

val word_log2_33 =
  wordsTheory.LOG2_w2n_lt
  |> Q.INST_TYPE [`:'a` |-> `:33`]
  |> SIMP_RULE (srw_ss()) []

val E_bound_lem = Q.prove(
  `!t b. let (E, E_overflow) = compute_E t b in
           E < 25 + E_overflow`,
  rw [compute_E_def, HighestSetBit_def, wordsTheory.word_log2_def]
  \\ fs []
  \\ imp_res_tac word_log2_33
  \\ simp [arithmeticTheory.LESS_MOD]
  \\ rule_assum_tac (REWRITE_RULE [GSYM wordsTheory.w2n_eq_0])
  \\ simp [bitTheory.LT_TWOEXP
           |> Drule.SPEC_ALL
           |> Q.DISCH `x <> 0`
           |> SIMP_RULE std_ss []
           |> GSYM, DECIDE ``a + 1n < 26 = a < 25n``]
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

fun word_lo q =
  wordsTheory.WORD_LO
  |> Q.SPECL [`x`, q]
  |> Q.INST_TYPE [`:'a` |-> `:33`]
  |> SIMP_RULE (srw_ss()) []
  |> GSYM

val E_properties = Count.apply Q.store_thm("E_properties",
  `!t b. let (E, E_overflow) = compute_E t b ;
             x = w2w (t - b) : word33
         in
           if E_overflow = 1 then
             x <+ (n2w (2 ** 7) << E) /\
             ((E + 6 >< E + 2) x = 0b11111w: word5)
           else
             (E_overflow = 0) /\
             (E <> 0 ==> x ' (E + 7)) /\
             x <+ (n2w (2 ** 8) << E) /\
             ((E + 7 >< E + 3) x <> 0b11111w: word5)`,
  rpt strip_tac
  \\ qspecl_then [`t`, `b`] mp_tac E_bound_lem
  \\ simp [compute_E_def]
  \\ CASE_TAC
  \\ simp []
  \\ qabbrev_tac `x = -1w * b + t`
  \\ pop_assum mp_tac
  \\ pop_assum kall_tac
  \\ (Cases_on `(w2w x >>> 7) = 0w : word33`
      >- (simp [HighestSetBit_def] \\ blastLib.FULL_BBLAST_TAC)
      \\ rpt strip_tac
      \\ rfs [HighestSetBit_def, DECIDE ``a + 1n < 26 = a < 25n``,
              word_lo `26w`, word_lo `25w`]
      \\ rule_assum_tac (CONV_RULE (TRY_CONV WORD_LESS_CONV))
      \\ rfs []
      \\ fs []
      \\ rev_full_simp_tac (std_ss++wordsLib.SIZES_ss)
               [log2_expand_thm
                |> Q.INST_TYPE [`:'a` |-> `:33`]
                |> SIMP_RULE (srw_ss()) []]
      \\ (EXPAND_RANGE_TAC
          \\ blastLib.MP_BLASTABLE_TAC
          \\ blastLib.BBLAST_PROVE_TAC))
  )

val cnv = SIMP_CONV std_ss [wordsTheory.NUMERAL_LESS_THM]

val lt25 = cnv ``x < 25n``
val lt26 = cnv ``x < 26n``

local
   val () = set_trace "print blast counterexamples" 0
   val () = set_trace "print blast counterexamples" 1
   val vname = fst o Term.dest_var
   fun fnd (s : (term, term) Term.subst) x =
     #residue (Option.valOf (List.find (fn {redex, ...} => vname redex = x) s))
   fun print_eq (name, t) =
     ( print ("\n" ^ StringCvt.padLeft #" " 12 name ^ " = ")
     ; Hol_pp.print_term t
     )
   val eval = boolSyntax.rhs o Thm.concl o EVAL
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
      ("vc4", ``b - (b_d: word32) <+ (1w : word32) << (E+2)``)]
in
(* val ss = ref ([] : (term, term) Term.subst) *)
   fun custom_bblast_prove_tac (goal as (asl, g)) =
     (print "."; blastLib.BBLAST_PROVE_TAC goal)
     handle HolSatLib.SAT_cex ctm =>
       let
         val c = boolSyntax.lhs (Thm.concl ctm)
         val s = fst (Term.match_term g c)
         val fnd = fnd s
         val t = fnd "t"
         val a = fnd "a"
         val b = fnd "b"
         val enc = encode t b
         val dec = decode a enc
         val s = List.map (op |->) (ListPair.zip (enc_tms, enc)) @ s
         val s = List.map (op |->) (ListPair.zip (dec_tms, dec)) @ s
       in
         print "\nCounterexample:\n"
       ; List.app print_eq [("t", t), ("a", a), ("b", b)]
       ; print "\n"
       ; List.app print_eq (ListPair.zip (["E", "t_cc", "b_c", "l_7"], enc))
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
                end) s decode_tms
(* for debug: val () = ss := s *)
           val pr = List.app (fn (name, tm) => print_eq (name, subst_eval s tm))
         in
           print "\n"
         ; pr extra_decode_tms
         ; print "\n"
         ; pr vcs
         end
       ; print "\n"
       ; raise ERR "custom_bblast_prove_tac" "found counterexample"
       end
end

val is_var_eq = Lib.can ((Term.dest_var ## Lib.I) o boolSyntax.dest_eq)

val proof1 = Count.apply Q.prove(
  `!a t b.
     let
       (E, t_cc, b_c, l_7) = encode t b ;
       (t_d, b_d) = decode E t_cc b_c a l_7;
       rep_edge = ((b - 1w << (E + 6)) >>> (E + 6)) << (E + 6)
     in
        rep_edge <=+ a /\
        a <+ rep_edge + (1w << (E + 9)) ==>
        (
(*vc1*) (w2w t <=+ t_d  /\
(*vc2*) t_d - (w2w t : word33) <=+ (1w : word33) << (E + 2)) /\
(*vc3*) (b_d <=+ b  /\
(*vc4*) b - b_d <+ (1w : word32) << (E + 2))
        )`,
  rpt strip_tac
  \\ simp [encode_def]
  \\ qabbrev_tac `x = compute_E t b`
  \\ Cases_on `x`
  \\ qmatch_asmsub_rename_tac `(E, E_overflow) = compute_E t b`
  \\ qspecl_then [`t`, `b`] assume_tac E_bound_lem
  \\ qspecl_then [`t`, `b`] assume_tac E_properties
  \\ rfs [decode_def, adjustment_def]
  \\ Cases_on `E_overflow = 1`
  \\ full_simp_tac std_ss [lt25, lt26]
  \\ rev_full_simp_tac std_ss []
  \\ ((fn g as (asl, _) =>
         ( print "\n"
         ; List.app (fn t => (print_term t; print " : "))
              (List.filter is_var_eq asl)
         ; all_tac g))
      \\ rpt CASE_TAC
      \\ rfs []
      \\ blastLib.MP_BLASTABLE_TAC
      \\ custom_bblast_prove_tac
     )
  )

val () = export_theory()
