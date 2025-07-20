% Stage 2 Generated Facts
% Case: s3306_a_1_B_neg
% Text: Alice has employed Bob on various occasions during the year 2017: - Jan 24 - Feb 4 - Mar 3 - Mar 18 - Apr 1 - Oct 25 - Nov 8 - Nov 22 - Dec 1 - Dec 2
% Question: Section 3306(a)(1)(B) applies to Alice for the year 2017. Contradiction

:- discontiguous s3306_a_1_B_applies/2.
:- ['statutes/prolog/init'].
s3306_a_1_B_applies("Alice", 2017).
employment_(span("employed", 10, 17)).
agent_(span("employed", 10, 17), span("Alice", 0, 4)).
patient_(span("employed", 10, 17), span("Bob", 19, 21)).
start_(span("employed", 10, 17), span(20170124, 62, 67)).
start_(span("employed", 10, 17), span(20170204, 71, 75)).
start_(span("employed", 10, 17), span(20170303, 79, 83)).
start_(span("employed", 10, 17), span(20170318, 87, 92)).
start_(span("employed", 10, 17), span(20170401, 96, 100)).
start_(span("employed", 10, 17), span(20171025, 104, 109)).
start_(span("employed", 10, 17), span(20171108, 113, 117)).
start_(span("employed", 10, 17), span(20171122, 121, 126)).
start_(span("employed", 10, 17), span(20171201, 130, 134)).
start_(span("employed", 10, 17), span(20171202, 138, 142)).
