% File: cases_data.pl
:- module(cases_data,[
    case_expected/2,
    case_type/2,
    case_params/2
]).

% case_expected(CaseID, true|false).
case_expected(tax_case_99,        true).
case_expected(s152_c_3_neg,       false).
case_expected(s3301_neg,          false).
case_expected(s63_f_2_A_neg,      false).
case_expected(s63_c_7_i_pos,      true).
case_expected(s3306_b_2_C_pos,    true).
case_expected(tax_case_59,        true).
case_expected(s1_a_2_neg,         false).
case_expected(s7703_a_1_pos,      true).
case_expected(s152_c_2_A_pos,     true).
case_expected(s152_b_2_neg,       false).
case_expected(tax_case_69,        true).
case_expected(s3306_c_6_neg,      false).
case_expected(s1_a_1_iv_neg,      false).
case_expected(s151_d_3_B_pos,     true).
case_expected(s1_c_i_neg,         false).
case_expected(s1_b_v_neg,         false).
case_expected(s1_b_iii_neg,       false).
case_expected(s63_f_3_pos,        true).
case_expected(tax_case_25,        true).

% case_type(CaseID, tax|boolean).
case_type(tax_case_99,     tax).
case_type(s152_c_3_neg,    boolean).
case_type(s3301_neg,       boolean).
case_type(s63_f_2_A_neg,   boolean).
case_type(s63_c_7_i_pos,   boolean).
case_type(s3306_b_2_C_pos, boolean).
case_type(tax_case_59,     tax).
case_type(s1_a_2_neg,      boolean).
case_type(s7703_a_1_pos,   boolean).
case_type(s152_c_2_A_pos,  boolean).
case_type(s152_b_2_neg,    boolean).
case_type(tax_case_69,     tax).
case_type(s3306_c_6_neg,   boolean).
case_type(s1_a_1_iv_neg,   boolean).
case_type(s151_d_3_B_pos,  boolean).
case_type(s1_c_i_neg,      boolean).
case_type(s1_b_v_neg,      boolean).
case_type(s1_b_iii_neg,    boolean).
case_type(s63_f_3_pos,     boolean).
case_type(tax_case_25,     tax).

% case_params(CaseID, Params).
% tax cases: [StatusAtom, TaxableIncome, ExpectedRoundedTax]
case_params(tax_case_99,   [joint,          75845,   15037]).
case_params(tax_case_59,   [married_separate, 73200-12000, 15236]).
case_params(tax_case_69,   [single,         718791-12000, 264225]).
case_params(tax_case_25,   [joint,          324311+414231-6000, 259487]).

% boolean cases:
case_params(s152_c_3_neg,    [qualifying_child,      bob,   alice, 2019]).
case_params(s3301_neg,       [excise_tax,            443870, 26362]).
case_params(s63_f_2_A_neg,   [applies_section63_f2A, bob,    2017]).
case_params(s63_c_7_i_pos,   [basic_standard,        head_of_household, 18000]).
case_params(s3306_b_2_C_pos, [wages_excluded_3306b2C, alice, 2017]).
case_params(s1_a_2_neg,      [tax_section1a,         single, 210204, 65445]).
case_params(s7703_a_1_pos,   [marital_status,        alice, 2012, married]).
case_params(s152_c_2_A_pos,  [relationship_descendant, alice, bob]).
case_params(s152_b_2_neg,    [section152b2_applies,  alice, 2015]).
case_params(s3306_c_6_neg,   [section3306_c6_applies, alice, 2017]).
case_params(s1_a_1_iv_neg,   [tax_bracket_iv,        joint,  684642]).
case_params(s151_d_3_B_pos,  [applicable_percentage, 276932, 250000, 22]).
case_params(s1_c_i_neg,      [tax_bracket_c_i,       single, 718791]).
case_params(s1_b_v_neg,      [tax_bracket_b_v,       head_of_household, 194512]).
case_params(s1_b_iii_neg,    [tax_bracket_b_iii,     head_of_household, 54775]).
case_params(s63_f_3_pos,     [additional_standard_unmarried_amount, alice, 2017, 750]).
