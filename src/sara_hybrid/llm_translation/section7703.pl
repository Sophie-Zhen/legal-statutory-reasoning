% ----- section7703.pl -----
:- module(section7703,
          [ married_under_section_7703/2,   % Person × Year
            files_joint_return/2            % Person × Year
          ]).

%% § 7703: who counts as “married”
married_under_section_7703(alice, 2017).

%% joint‐return fact
files_joint_return(alice, 2017).