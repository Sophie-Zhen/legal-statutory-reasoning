% Stage 2 Generated Facts
% Case: tax_case_82
% Text: In 2012, Alice was paid $54268 in remuneration. In addition, Alice has paid $11571 to Bob for work done from Feb 1st, 2012 to Sep 1st, 2012, in Caracas, Venezuela. Alice is an American employer, and Bob is an American citizen. Bob takes the standard deduction in 2012.
% Question: How much tax does Bob have to pay in 2012? $986

:- ['statutes/prolog/init'].
income_(span("paid",20,23)).
patient_(span("paid",20,23),span("Alice",10,14)).
amount_(span("paid",20,23),span(54268,25,30)).
start_(span("paid",20,23),span(2012,3,6)).
payment_(span("paid",62,65)).
agent_(span("paid",62,65),span("Alice",56,60)).
patient_(span("paid",62,65),span("Bob",77,79)).
amount_(span("paid",62,65),span(11571,67,72)).
start_(span("paid",62,65),span(20120201,98,110)).
end_(span("paid",62,65),span(20120901,115,127)).
location_(span("paid",62,65),span("Caracas, Venezuela",133,150)).
american_employer_(span("American employer",158,174)).
patient_(span("American employer",158,174),span("Alice",152,156)).
american_citizen_(span("American citizen",183,198)).
patient_(span("American citizen",183,198),span("Bob",179,181)).
takes_standard_deduction_(span("takes the standard deduction",204,229)).
agent_(span("takes the standard deduction",204,229),span("Bob",200,202)).
start_(span("takes the standard deduction",204,229),span(2012,234,237)).
