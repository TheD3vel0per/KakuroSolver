%% sublist(List, I, J, Sublist) is true if Sublist is the sublist of List starting from index I to index J.
sublist(List, I, J, Sublist) :-
    sublist(List, I, J, 0, Sublist).

% Base case: If we reach the end of the list, return an empty list.
sublist([], _, _, _, []).

% If Index is less than I, skip elements until we reach I.
sublist([_|T], I, J, Index, Sublist) :-
    Index < I,
    NextIndex is Index + 1,
    sublist(T, I, J, NextIndex, Sublist).

% If Index is within the range of I to J, include the current element in the Sublist.
sublist([H|T], I, J, Index, [H|Sublist]) :-
    Index >= I,
    Index =< J,
    NextIndex is Index + 1,
    sublist(T, I, J, NextIndex, Sublist).

% If we have passed index J, terminate the sublist.
sublist(_, _, J, J, []).


% skiplist(List, N, Sublist) is true if Sublist contains every Nth element of List.
skiplist(List, N, Sublist) :-
    skiplist(List, N, N, Sublist).

% Base case: If the list is empty, return an empty sublist.
skiplist([], _, _, []).

% If the current index is not equal to N, skip the element.
skiplist([_|T], N, Index, Sublist) :-
    Index > 1,
    NextIndex is Index - 1,
    skiplist(T, N, NextIndex, Sublist).

% If the current index is equal to N, include the element in the sublist.
skiplist([H|T], N, 1, [H|Sublist]) :-
    skiplist(T, N, N, Sublist).