%%%%%%%%%%%%%%%%%%
%%%%          %%%%
%%%%   Main   %%%%
%%%%          %%%%
%%%%%%%%%%%%%%%%%%

main :-
    write("Enter a kakuro board.\n"),
    read(Board),
    write(kakuro_solution(Board)).

%%%%%%%%%%%%%%%%%%
%%%%          %%%%
%%%%   Data   %%%%
%%%%          %%%%
%%%%%%%%%%%%%%%%%%

% Board = Dictionary of Tiles

% Tile is one of:
% - Open Tile
% - Closed Tile
% - Head Tile

% BOARDS:
% Board 1
% board(4, [
%     tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
%     tile_head(0, 9),    tile_open(A),       tile_open(B),       tile_closed, 
%     tile_closed,        tile_open(C),       tile_open(D),       tile_closed, 
%     tile_closed,        tile_closed,        tile_closed,        tile_closed
% ])

% Board 2
% board(5, [
%     tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
%     tile_head(0, 8),    tile_open(_),       tile_open(_),       tile_open(_),      tile_closed,  
%     tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
%     tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
%     tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
% ])

% Board 3
% board(6, [
%     tile_closed,        tile_closed,        tile_head(21, 0),   tile_closed,       tile_closed,
%     tile_closed,        tile_open(_),       tile_open(_),       tile_open(_),      tile_closed,  
%     tile_closed,        tile_open(_),       tile_open(_),       tile_closed,       tile_closed, 
%     tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
%     tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
% ])

% board(Size, Tiles) where
%   Size is a number
%   Tiles is an array of tile | 

% tile_open(_)
tile_open(_).

% tile_closed.
tile_closed.

% tile_head(V, H)
%   V is a number
%   H is a number

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                  %%%%
%%%%   Verification   %%%%
%%%%                  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%


kakuro_solution(Board) :-
    all_rows_correct(Board),
    all_columns_correct(Board).


all_rows_correct(Board) :-
    all_rows_correct(Board, 0).
all_rows_correct(Board, Index) :-
    row_correct(Board, Index),
    NextIndex is Index + 1,
    all_rows_correct(Board, NextIndex).
all_rows_correct(board(Size, _), Size).


all_columns_correct(Board) :-
    all_columns_correct(Board, 0).
all_columns_correct(Board, Index) :-
    row_correct(Board, Index),
    NextIndex is Index + 1,
    all_columns_correct(Board, NextIndex).
all_columns_correct(board(Size, _), Size).


row_correct(Board, R) :-
    row(Board, R, Row),
    segment(Row, Segment),
    inner_segment(Segment, tile_head(_, H), InnerSegment),
    tile_open_values(InnerSegment, Values),
    are_valid_digits(Values),
    are_unique_digits(Values),
    sum_values(Values, H).


column_correct(Board, C) :-
    column(Board, C, Column),
    segment(Column, Segment),
    inner_segment(Segment, tile_head(V, _), InnerSegment),
    tile_open_values(InnerSegment, Values),
    are_valid_digits(Values),
    are_unique_digits(Values),
    sum_values(Values, V).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                    %%%%
%%%%   Rows & Columns   %%%%
%%%%                    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


row(board(Size, Tiles), R, Row) :-
    I is R * Size,
    J is (R + 1) * Size,
    sublist(Tiles, I, J, Row).


column(board(Size, Tiles), C, Column) :-
    TilesLength is Size * Size,
    sublist(Tiles, 0, TilesLength, NewTiles),
    skiplist(NewTiles, C, Column).


segment([Tile:RestTiles], Segment) :-
    segment(RestTiles, Segment).

segment(Tiles, Segment) :-
    append(Tiles2, [_], Tiles),
    segment(Tiles2, Segment).

segment(Tiles, Tiles) :-
    match_start(tile_head(_, _), Tiles),
    match_end(tile_close, Tiles).

segment([], []).

%%%%%%%%%%%%%%%%%%%%%
%%%%             %%%%
%%%%   Helpers   %%%%
%%%%             %%%%
%%%%%%%%%%%%%%%%%%%%%


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


% match_start(Start, List) is true if START is the first element of List
match_start(Start, [Start|_]).

% match_end(END, LIST) is true if START is the last element of List
match_end(End, [End]).
match_end(End, [_|Tail]) :-
    match_end(End, Tail).

% are_valid_digits(Tiles) is True when every tile in an array with a number is a digit [1...9]
%     Assumption: all tiles are open 
are_valid_digits([]).
are_valid_digits([H|T]) :- is_digit(H), are_valid_digits(T). 

% is_digit(X) is True when X is a digit [1...9]
is_digit(X) :- member(X, [1,2,3,4,5,6,7,8,9]).

% are_unique_digits(Tiles) is True when every tile in an array with a number is unique 
are_unique_digits([]).
are_unique_digits([X|Y]) :- are_unique_digits(Y), notmember(X,Y). 

% notmember(X,Y) is True when X and Y are not the same (i.e. are unique to each other)
notmember(X,Y) :- \+member(X,Y).

% tile_open_values(Tiles, Values) is True when every element of Tiles is tile_open(Value) and every element of Values is Value
tile_open_values([], []).
tile_open_values([tile_open(TileValue)|RestTiles], [Value|RestValues]) :-
    tile_open_values(RestTiles, RestValues).

% inner_segment(Segment, TileHead, InnerSegment) is True when Segment starts with a tile_head(V, H), has at least one tile_open(X) in the middle, and terminates with a tile_close
inner_segment([TileHead, RemainingSegment], TileHead, InnerSegment) :-
    append(InnerSegment, [tile_close], RemainingSegment).

% sum_values(Values, SummedValue)
sum_values([], 0).
sum_values([Value|RestValues], SummedValue) :-
    sum_list(RestValues, RestSum),
    SummedValue is Value + RestSum.


%%%%%%%%%%%%%%%%%%%
%%%%           %%%%
%%%%   Tests   %%%%
%%%%           %%%%
%%%%%%%%%%%%%%%%%%%

% Board 1, Row 0
row(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    0,
    [tile_closed, tile_head(15, _), tile_head(6, _), tile_closed]
).

% Board 1, Row 1
row(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    1,
    [tile_head(_,9), tile_open(_), tile_open(_), tile_closed]
).

% Board 1, Row 2
row(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    2,
    [tile_closed, tile_open(_), tile_open(_), tile_closed]
).

% Board 1, Row 3 
row(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    3,
    [tile_closed, tile_closed, tile_closed, tile_closed]
).

% Board 2, Row 0
row(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    0,
    [tile_closed, tile_head(12,0), tile_closed, tile_closed, tile_closed]
).

% Board 2, Row 1
row(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    1,
    [tile_head(_, 8), tile_open(_), tile_open(_), tile_open(_), tile_closed]
).

% Board 2, Row 2
row(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    2,
    [tile_closed, tile_open(_), tile_closed, tile_closed, tile_closed]
).

% Board 2, Row 3
row(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    3,
    [tile_closed, tile_open(_), tile_closed, tile_closed, tile_closed]
).

% Board 2, Row 4
row(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    4,
    [tile_closed, tile_closed, tile_closed, tile_closed, tile_closed]
).

% Board 1, Column 0 
column(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    0,
    [tile_closed, tile_head(_, 9), tile_closed, tile_closed]
).

% Board 1, Column 1
column(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    1,
    [tile_head(15, _), tile_open(_), tile_open(_), tile_closed]
).

% Board 1, Column 2
column(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    2,
    [tile_head(6, _), tile_open(_), tile_open(_), tile_closed]
).

% Board 1, Column 3
column(
    board(4, [
        tile_closed,        tile_head(15, _),   tile_head(6, _),    tile_closed, 
        tile_head(_, 9),    tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_open(_),          tile_open(_),          tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ]),
    3,
    [tile_closed, tile_closed, tile_closed, tile_closed]
).

% Board 2, Column 0
column(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    0,
    [tile_closed, tile_head(_, 8), tile_closed, tile_closed, tile_closed]
).

% Board 2, Column 1
column(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    1,
    [tile_head(12, _), tile_open(_), tile_open(_), tile_open(_), tile_closed]
).

% Board 2, Column 2
column(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    2,
    [tile_closed, tile_open(_), tile_closed, tile_closed, tile_closed]
).

% Board 2, Column 3
column(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),          tile_open(_),          tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),          tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    3,
    [tile_closed, tile_open(_), tile_closed, tile_closed, tile_closed]
).

% Board 2, Column 4
column(
    board(5, [
        tile_closed,        tile_head(12, _),   tile_closed,        tile_closed,      tile_closed, 
        tile_head(_, 8),    tile_open(_),       tile_open(_),       tile_open(_),        tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,      tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,      tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,      tile_closed
    ]),
    4,
    [tile_closed, tile_closed, tile_closed, tile_closed, tile_closed]
).

% Segment Tests
segment(
    [],
    []
). 

segment(
    [tile_closed],
    []
).
segment(
    [tile_closed, tile_closed, tile_closed, tile_closed], 
    []
). 

segment(
    [tile_head(_,_), tile_open, tile_closed], 
    [tile_head(_,_), tile_open, tile_closed]
).

segment(
    [tile_closed, tile_head(_), tile_open(_), tile_open(_), tile_closed],
    [tile_head(_), tile_open(_), tile_open(_), tile_closed]
). 

segment(
    [tile_closed, tile_head(_, _), tile_open(_), tile_closed, tile_head(_, _), tile_open(_), tile_closed],
    [tile_head(_, _), tile_open(_), tile_closed]
).

segment(
    [tile_closed, tile_head(_, _), tile_open(_), tile_closed, tile_head(_, _), tile_open(_), tile_closed],
    [tile_head(_, _), tile_open(_), tile_closed]
).

segment(
    [tile_closed, tile_closed, tile_head(_,_), tile_open, tile_open, tile_open, tile_closed],
    [tile_head(_,_), tile_open, tile_open, tile_open]
).

% Tests for Row_Correct

not(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(4),       tile_open(0),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)).

not(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(3),       tile_open(3),       tile_open(2),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)).

not(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(5),       tile_open(3),       tile_open(1),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)).

not(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(5),       tile_open(3),       tile_open(0),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)).

(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(1),       tile_open(3),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)).

(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(2),       tile_open(1),       tile_open(5),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)).

(row_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(5),       tile_open(2),       tile_open(1),      tile_closed,  
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(_),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

% Tests for column_correct
(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(5),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(6),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(1),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(3),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(5),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(2),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(9),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(1),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

not(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(0),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(9),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(3),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

not(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(5),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(5),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(2),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

not(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(6),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(6),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(0),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

not(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(7),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(8),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(1),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

not(column_correct(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(_),       tile_open(_),      tile_closed,  
        tile_closed,        tile_open(3),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(2),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ]), 1 
)). 

% Tests for kakuro_solution(Board)

(kakuro_solution(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(3),       tile_open(1),      tile_closed,  
        tile_closed,        tile_open(5),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(3),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ])
)). 

(kakuro_solution(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(5),       tile_open(2),       tile_open(1),      tile_closed,  
        tile_closed,        tile_open(2),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(6),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ])
)). 

(kakuro_solution(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(1),       tile_open(3),       tile_open(4),      tile_closed,  
        tile_closed,        tile_open(9),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(2),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ])
)). 

not(kakuro_solution(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(3),       tile_open(3),       tile_open(2),      tile_closed,  
        tile_closed,        tile_open(4),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(6),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ])
)). 

not(kakuro_solution(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(3),       tile_open(1),      tile_closed,  
        tile_closed,        tile_open(6),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(3),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ])
)). 

not(kakuro_solution(
    board(5, [
        tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
        tile_head(0, 8),    tile_open(4),       tile_open(3),       tile_open(1),      tile_closed,  
        tile_closed,        tile_open(4),       tile_closed,        tile_closed,       tile_closed, 
        tile_closed,        tile_open(4),       tile_closed,        tile_closed,       tile_closed,
        tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
 ])
)). 

(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(7),       tile_open(2),       tile_closed, 
        tile_closed,        tile_open(8),       tile_open(4),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
 ])
)).

(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(8),       tile_open(1),       tile_closed, 
        tile_closed,        tile_open(7),       tile_open(5),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
 ])
)).

not(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(4),       tile_open(5),       tile_closed, 
        tile_closed,        tile_open(11),       tile_open(1),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
 ])
)).

not(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(6),       tile_open(3),       tile_closed, 
        tile_closed,        tile_open(9),       tile_open(3),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
 ])
)).

not(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(7),       tile_open(2),       tile_closed, 
        tile_closed,        tile_open(9),       tile_open(4),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
 ])
)).

not(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(9),       tile_open(0),       tile_closed, 
        tile_closed,        tile_open(6),       tile_open(6),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
 ])
)).

not(kakuro_solution(
    board(4, [
        tile_closed,        tile_head(15, 0),   tile_head(6, 0),    tile_closed, 
        tile_head(0, 9),    tile_open(10),      tile_open(1),       tile_closed, 
        tile_closed,        tile_open(9),       tile_open(4),       tile_closed, 
        tile_closed,        tile_closed,        tile_closed,        tile_closed
    ])
)).

kakuro_solution(
    board(3, [
        tile_closed,        tile_head(3, 0),    tile_closed, 
        tile_head(0, 3),    tile_open(X),       tile_closed,
        tile_closed,        tile_closed,        tile_closed
    ])
).