/*
# Ben’s Facts
used_omnitrix(ben, heatblast),
attacked_downtown(vilgax, bank),
arrived_first(ben),
driving_muscle_car(kevin, mid_fight),
explosion_source(ben, vilgax, knocked_into_power_station),
post_fight_action(ben, transform_to_human, vilgax_defeated),
omnitrix_malfunction(ben, post_fight),
end_battle_indicator(explosion),
end_battle_indicator(explosion).

# Ben’s Rules
defeats_villain(ben),
leads_battle(ben),
is_savior(ben),
not_at_scene(kevin),
malfunction_reason(ben, overuse).

# Kevin's Facts

*/

% =================================
% Grouped Facts
% =================================
% Format: Top - Ben, Bottom - Kevin

% arrived_first/1
% who
arrived_first(ben).
arrived_first(kevin).

% used_omnitrix/2
% who, what
used_omnitrix(ben, heatblast).
used_omnitrix(ben, diamondhead).

% attacked_downtown/2
% who, where
attacked_downtown(vilgax, bank).
attacked_downtown(vilgax, power_station).

% driving_muscle_car/2
% who, when
% Note: undisputed
driving_muscle_car(kevin, mid_fight).
% driving_muscle_car(kevin, mid_fight).

% explosion_source/3
% party1, party2, how
explosion_source(ben, vilgax, knocked_into_power_station).
explosion_source(kevin, vilgax, punched_into_transformer).

% vilgax_fate/1
% what
vilgax_fate(defeated).
vilgax_fate(escaped). 

% final_blow/1
% final_blow data as just implied facts
% who
% Note: no explicit facts/rules
% final_blow(ben).
% final_blow(kevin).

% post_fight_action/3
% who, what, why
post_fight_action(ben, transform_to_human, vilgax_defeated).
post_fight_action(kevin, rescued_ben, explosion).

% omnitrix_malfunction/2
% who, when
omnitrix_malfunction(ben, post_fight).
omnitrix_malfunction(ben, mid_fight).

% =================================
% Ungrouped Facts
% =================================

% Ben's
end_battle_indicator(explosion).
end_battle_indicator(explosion).

% Kevin's
pre_explosion(ben, knocked_out).
destroyed_ship(vilgax, explosion).
post_fight(vilgax, escaped).

% =================================
% Character Rules
% =================================

% Ben's Rules
defeats_villain(Person) :-
    final_blow(Person).

leads_battle(Hero) :-
    arrived_first(Hero),
    used_omnitrix(Hero, _).

is_savior(Person) :-
    leads_battle(Person),
    defeats_villain(Person).

not_at_scene(Person) :-
    driving_muscle_car(Person, pre_fight).

malfunction_reason(Person, overuse) :- % who, what
    omnitrix_malfunction(Person, post_fight), % should be a post-fight malfunction
	used_omnitrix(Person, _). % transformation occurrence

% Kevin's Rules
wins_battle(Person) :-  % Kevin implies he had the last blow based on his facts
	final_blow(Person),            
    vilgax_fate(escaped).          

not_winner(Hero) :- 
	pre_explosion(Hero, knocked_out).

is_true_hero(Person) :- % To check
	post_fight_action(Person, rescued_ben, _); 
    post_fight_action(Person, rescued_civilians, _).  

% Location claim by Ben: Fight happened in the bank
% Location claim by Kevin: Fight happened in power station (outside bank)
ben_location_false :-
    attacked_downtown(vilgax, power_station).

truly_defeated_vilgax(Fate) :-
    vilgax_fate(Fate),
    Fate = defeated.

% =================================
% 10 Truths - Gwen's Override Truths
% =================================

% #1
truth(arrived_first(ben)).
% #2
truth(attacked_downtown(vilgax, power_station)).
% #3
truth(used_omnitrix(ben, heatblast)).
truth(used_omnitrix(ben, diamondhead)).
truth(two_omnitrix_transformations) :-
    (
    	truth(used_omnitrix(ben, heatblast)); % OR
	    truth(used_omnitrix(ben, diamondhead))
    ).
% #4
truth(explosion_source(ben, heatblast_fire, power_station_strike)).
% #5
truth(vilgax_fate(defeated)).
truth(vilgax_post_defeat_fate(captured)).
truth(vilgax_defeated_then_captured) :-
    ( 
    	truth(vilgax_fate(defeated)),
        truth(vilgax_post_defeat_fate(captured))
    ).
% #6
truth(malfunction_reason(ben, overuse)).
% #7
truth(pre_explosion(ben, not_knocked_out)).
% #8
truth(post_fight_action(kevin, rescued_civilians, vilgax_defeated)). 
% #9
truth(arrived_after_five(police)).
truth(police_declared_hero(ben)).
truth(defeated_vilgax(Person)) :-
	(   
	    truth(arrived_after_five(police)),
        truth(police_declared_hero(Person))
    ).
% #10
truth(helped_saved_bellwood(ben)).
truth(helped_saved_bellwood(kevin)).
truth(team_saved_bellwood) :-
    ( 
    	truth(helped_saved_bellwood(ben)),
        truth(helped_saved_bellwood(kevin)),
        !
    ).

multi_truth_predicate(used_omnitrix).
multi_truth_predicate(helped_saved_bellwood).

% =================================
% Universal Contradiction Mapping
% =================================

% functor/3 in Prolog checks if A&B have the same functor 
% 		(same predicate name and arity)

% A claim contradicts Gwen's truth if:
% 1. Gwen has a truth term TruthTerm
% 2. The claim has the same predicate name and arity
% 3. The terms are NOT identical
contradicts(Claim, TruthTerm) :-
    truth(TruthTerm),
    functor(Claim, Name, Arity), % extract name and arity
    functor(TruthTerm, Name, Arity), % expect name and arity
    Claim \= TruthTerm,
    \+ multi_truth_predicate(Name). % multi_truths do not contradict each other

% =================================
% Verified Claim (truth override)
% =================================

% If there's contradiction with Gwen's truth, the claim is FALSE
verified_claim(Claim) :-
    contradicts(Claim, TruthTerm),
    truth(TruthTerm),
    !,
    fail.

% Check for gaps

% Otherwise, claim is TRUE if it exists in the database
verified_claim(Claim) :-
    call(Claim).
