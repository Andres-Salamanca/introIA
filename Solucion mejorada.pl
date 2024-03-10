% Dynamic declaration for en_habitacion/2
:- dynamic en_habitacion/2.

% Hechos iniciales
en_habitacion(azul, h1).
en_habitacion(roja, h1).
en_habitacion(robot, h1).

conectadas(h1, h2).
conectadas(h2, h1).

% Reglas para mover el robot
mover(Objeto, Desde, Hacia) :-
    %write('Explorando Objeto: '), write(Objeto), nl,
    conectadas(Desde, Hacia),  % Verifica que las habitaciones estén conectadas
    %write('Explorando despues conectadas(Desde, Hacia): '), nl,
    (en_habitacion(Objeto, Desde) ->
        write('Objeto '), write(Objeto), write(' está en la habitación '), write(Desde), nl
    ;
        write('Objeto '), write(Objeto), write(' NO está en la habitación '), write(Desde), nl
    ),
    %write('Explorando despues en_habitacion(Objeto, Desde): '), nl,
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
    %write('heuristica Objeto: '), write(Objeto), nl,
    %write('heuristica H1: '), write(H1), nl,
    %write('heuristica H2: '), write(H2), nl,
    distancia(H1, H2, Distancia),
    Valor is Distancia + 1.

distancia(h1, h2, 1).
distancia(h2, h1, 1).
distancia(h2, h2, 0).

mover_setup(Objeto, Desde, Hacia) :-
    (en_habitacion(Objeto, Desde) ->
        write('Objeto '), write(Objeto), write(' está en la habitación '), write(Desde), nl
    ;
        write('Objeto '), write(Objeto), write(' NO está en la habitación '), write(Desde), nl
    ),
    retract(en_habitacion(Objeto, Desde)),
    asserta(en_habitacion(Objeto, Hacia)).

colocar_objetos_en_posicion(estado(Robot, Azul, Roja, _)) :-
    % Llama a mover_setup para colocar los objetos en la posición del estado
    mover_setup(robot, _, Robot),
    mover_setup(azul, _, Azul),
    mover_setup(roja, _, Roja).


% Algoritmo de búsqueda Best First
buscar :-
    best_first([estado(h1, h1, h1,0)], Solucion),
    write('Solucion encontrada: '), write(Solucion).

best_first([Estado | _], Estado) :-
    write('Explorando estado: '), write(Estado), nl,
    colocar_objetos_en_posicion(Estado),
    objetivo.


best_first([Estado | Resto], Solucion) :-
    write('Explorando estado: '), write(Estado), nl,
    expandir(Estado, Hijos),
    write('Hijos generados: '), write(Hijos), nl,
    append(Resto, Hijos, NuevaLista),
    best_first(NuevaLista, Solucion).




%expandir(estado(Robot, Azul, Roja, Valor), Hijos) :-
 %   findall(Hijo, (
  %      write('antes mover 1: '), nl,
   %     mover(robot, Robot, NuevaPosRobot),
    %    write('NuevaPosRobot: '), write(NuevaPosRobot), nl,
     %   mover(azul, Azul, NuevaPosAzul),
     %   write('NuevaPosAzul: '), write(NuevaPosAzul), nl,
      %  mover(roja, Roja, NuevaPosRoja),
     %   write('NuevaPosRoja: '), write(NuevaPosRoja), nl,
   %     heuristica(azul, NuevaPosAzul, h2, ValorHeuristica),
   %     Hijo = estado(NuevaPosRobot, NuevaPosAzul, NuevaPosRoja, ValorHeuristica)
  %  ), Hijos).


expandir(estado(Robot, Azul, Roja, Valor), Hijos) :-
    findall(Hijo, (
        (mover(robot, Robot, NuevaPosRobot), % Mover solo al robot
         mover(azul, Azul, NuevaPosAzul), % Mover solo la caja azul
         heuristica(azul, NuevaPosAzul, h2, ValorHeuristica1),
         mover(robot, NuevaPosRobot, _), % Devolver al robot a su posición original
        mover(azul, NuevaPosAzul, _), % Devolver al azul a su posición original
         Hijo = estado(NuevaPosRobot, NuevaPosAzul, Roja, ValorHeuristica1));

        (mover(robot, Robot, NuevaPosRobot), % Mover solo al robot
         mover(roja, Roja, NuevaPosRoja), % Mover solo la caja roja
         heuristica(roja, NuevaPosRoja, h1, ValorHeuristica2),
         mover(robot, NuevaPosRobot, _), % Devolver al robot a su posición original
        mover(roja, NuevaPosRoja, _), % Devolver al roja a su posición original
         Hijo = estado(NuevaPosRobot, Azul, NuevaPosRoja, ValorHeuristica2))
    ), Hijos).



