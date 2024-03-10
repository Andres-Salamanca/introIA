% Dynamic declaration for en_habitacion/2
:- dynamic en_habitacion/2.

% Hechos iniciales
en_habitacion(azul, h1).
en_habitacion(roja, h1).
en_habitacion(robot, h1).

conectadas(h1, h2).

% Reglas para mover el robot
mover(Objeto, Desde, Hacia) :-
    write('Explorando Objeto: '), write(Objeto), nl,
    conectadas(Desde, Hacia),  % Verifica que las habitaciones estén conectadas
    en_habitacion(Objeto, Desde),  % Verifica que el objeto esté en la habitación actual
    retract(en_habitacion(Objeto, Desde)),
    asserta(en_habitacion(Objeto, Hacia)),
    write('Moviendo '), write(Objeto), write(' de '), write(Desde), write(' a '), write(Hacia), nl.


% Regla para verificar el estado objetivo
objetivo :-
    en_habitacion(azul, h2),
    en_habitacion(robot, h2),
    en_habitacion(roja, h1).

% Reglas para la heurística Best First
heuristica(Objeto, H1, H2, Valor) :-
    write('heuristica Objeto: '), write(Objeto), nl,
    write('heuristica H1: '), write(H1), nl,
    write('heuristica H2: '), write(H2), nl,
    distancia(H1, H2, Distancia),
    Valor is Distancia + 1.

distancia(h1, h2, 1).
distancia(h2, h1, 1).
distancia(h2, h2, 0).

% Algoritmo de búsqueda Best First
buscar :-
    best_first([estado(h1, h1, h1)], Solucion),
    write('Solucion encontrada: '), write(Solucion).

best_first([Estado | _], Estado) :-
    write('Explorando estado: '), write(Estado), nl,
    objetivo.


best_first([Estado | Resto], Solucion) :-
    write('Explorando estado: '), write(Estado), nl,
    expandir(Estado, Hijos),
    write('Hijos generados: '), write(Hijos), nl,
    append(Resto, Hijos, NuevaLista),
    best_first(NuevaLista, Solucion).

expandir(estado(Robot, Azul, Roja), Hijos) :-
    findall(Hijo, (
        mover(robot, Azul, NuevaPos),  % Mover solo el robot
        write('NuevaPos: '), write(NuevaPos), nl,
        mover(azul, Azul, NuevaPos),      % Mover la caja azul junto con el robot
		write('despues de mover: '), nl,
        heuristica(Azul, NuevaPos, h2, Valor),
		write('despues de heuristica: '), nl,
        Hijo = estado(NuevaPos, NuevaPos, Roja, Valor)
    ), Hijos),
    write('Hijos generados: '), write(Hijos), nl.