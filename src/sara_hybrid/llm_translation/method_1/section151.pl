% ----- section151.pl -----
:- module(section151,
          [ exemption_base/3,             % Person × Year × BaseExemption
            applicable_pct/3              % Person × Year × Percentage
          ]).

%% § 151(c): exemption amount before reduction
exemption_base(alice, 2015, 2000).

%% § 151(d)(3)(B): applicable percentage
applicable_pct(alice, 2015, 0.10).