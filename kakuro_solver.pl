%% Kakuro Solver by Devam and Kayla 

%% Problems:
% problem(Id, N, Blanks) :-
% Id: Id's each problem number
% N = number of tiles = N^2
% Blanks = where the blanks are and how many there are    

/* 
Problem 1
           5 0 2
           3 4 1 
           6 7 9    
*/
problem(Id, N, Blanks) :-
    Id = 1,
    N = 3,
    Blanks = [
        [0,1], [0,2], 
        [1,0],
        [2,1]
    ].

/*
Problem 2 !!! input problem with N=4
           4  5  2  1  
           0  6  3  4
           9  3  1  0
           4  8  7  2 
*/
problem(Id, N, Blanks) :-
    Id = 2,
    N = 4, 
    Blanks = [
        [0,0], [0,1], [0,2],
        [1,0], [1,2],
        [2,0], 
        [3,1], [3,2]
    ]. 

/*
Problem 3 
            6 8 7
            0 1 5
            3 2 9
*/
problem(Id, N, Blanks) :-
    Id = 3, 
    N = 3, 
    Blanks = [
        [0,0], [0,1],
        [1,0], 
        [2,0], [2,1]
    ].

% has_width(W, [X]) is True if matrix X has width W
has_width(W, [L]) :-
    length(L, W). 

has_width(W, [[H|T2]|T]) :- 
    length([H|T2], W),
    has_width(W,T). 

% has_height(H,L) is True if list X has height H
has_height(H,L) :- 
    length(L,H). 

% print_this(X) will print the matrix X
print_this([H|T]) :-
        writeln(H), 
        print(T), 
    print_this([]). 

% initialize_matrix is True if the position (G,F) of matrix X has the value V
initialize_matrix(X, G, F, V) :-
    nth0(G, X, Line),
    nth0(F, Line, V).
    
% blanks(X, N, B) is True when matrix X has 0 at correct positions in the list B
blanks(_, _, []).
blanks(X, N, [H|T]) :-
    has_width(N,X),
    has_height(N,X),
    is_matrix_digits(X),
    [G,F] = H,
    initialize_matrix(X, G, F, 0),
    blanks(X, N, T). 

% find_line(P, X, L) is True when L (Line) has the numbers specific to a P (Position)
find_line([[G,F]|T1], X, [H|T2]) :-
    initialize_matrix(X, G, F, H), 
    find_line(T1, X, T2). 
find_line([], _, []). 

% is_matrix_digits(X) is True when all numbers in the matrix ar 0-9
is_matrix_digits(X) :-
    all_dig(X).
all_dig([H|T]) :- 
    all_digits(H),
    all_dig(T).
all_dig([]). 

% Helper function all_digits
all_digits([]). 
all_digits([H|T]) :- is_digit(H), all_digits(T).
is_digit(X) :- member(X, [0,1,2,3,4,5,6,7,8,9]).

% -----------------------------------------------------------
% KAKURO GAME
kakuro(List, Sum) :- all_digits(List), all_different(List), sum_list(List, Sum). 

% all_different is True if all digits are unique (not the same)
all_different([]). 
all_different([X|Y]) :- all_different(Y), notmember(X,Y). 

notmember(X,Y) :- \+member(X,Y). 

sum_list([], 0). 
sum_list([X|Y], S) :- sum_list(Y,S1), S is S1 + X. 
