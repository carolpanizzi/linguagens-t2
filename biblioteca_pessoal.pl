/*
 * Integrantes: Carolina Panizzi, Paulo Trevisan, Isabella Zarosa
 * 
 * Consultas de exemplo:
 *   ?- livros_por_autor('Machado de Assis', Titulo).
 *   ?- livros_antigos(1900, Titulo).
 *   ?- disponivel(Titulo).
 *   ?- livros_emprestados_por('Maria Silva', Titulo).
 *   ?- inserir_livro('Memorial de Aires', 'Machado de Assis', 1908, 'Romance').
 *   ?- emprestar_livro('Dom Casmurro', 103, '2026-11-03').
 *   ?- devolver_livro('Dom Casmurro').
 *
 * Titulos identificam exemplares unicos; nomes de autores sao unicos.
 * Anos sao inteiros (negativos representam anos antes de Cristo).
 * As alteracoes duram a sessao atual. Recarregar o arquivo restaura os fatos.
 * Para novos autores, usar cadastrar_autor/2 antes de inserir o livro.
 * Datas sao atomos no formato AAAA-MM-DD, com validacao do calendario.
 */

:- encoding(utf8).
:- use_module(library(readutil)).
:- dynamic livro/4, autor/2, pessoa/2, emprestado/3.

autor('Machado de Assis', 'Brasileira').
autor('Clarice Lispector', 'Brasileira').
autor('George Orwell', 'Britanica').
autor('Sun Tzu', 'Chinesa').

livro('Dom Casmurro', 'Machado de Assis', 1899, 'Romance').
livro('Memorias Postumas de Bras Cubas', 'Machado de Assis', 1881, 'Romance').
livro('A Hora da Estrela', 'Clarice Lispector', 1977, 'Romance').
livro('1984', 'George Orwell', 1949, 'Distopia').
livro('A Revolucao dos Bichos', 'George Orwell', 1945, 'Fabula').
livro('A Arte da Guerra', 'Sun Tzu', -500, 'Estrategia').

pessoa('Maria Silva', 101).
pessoa('Joao Santos', 102).
pessoa('Ana Souza', 103).

emprestado('1984', 101, '2026-10-20').
emprestado('A Hora da Estrela', 102, '2026-10-25').

livros_por_autor(Autor, Titulo) :-
    livro(Titulo, Autor, _, _).

livros_antigos(AnoMaximo, Titulo) :-
    integer(AnoMaximo),
    livro(Titulo, _, Ano, _),
    Ano =< AnoMaximo.

disponivel(Titulo) :-
    livro(Titulo, _, _, _),
    \+ emprestado(Titulo, _, _).

livros_emprestados_por(NomePessoa, Titulo) :-
    pessoa(NomePessoa, Identificador),
    emprestado(Titulo, Identificador, _).

texto_valido(Texto) :-
    atom(Texto),
    normalize_space(atom(Limpo), Texto),
    Limpo \== ''.

cadastrar_autor(Nome, Nacionalidade) :-
    texto_valido(Nome), texto_valido(Nacionalidade),
    \+ autor(Nome, _),
    assertz(autor(Nome, Nacionalidade)).

cadastrar_pessoa(Nome, Identificador) :-
    texto_valido(Nome), integer(Identificador), Identificador > 0,
    \+ pessoa(_, Identificador),
    assertz(pessoa(Nome, Identificador)).

inserir_livro(Titulo, Autor, Ano, Categoria) :-
    texto_valido(Titulo), texto_valido(Autor), texto_valido(Categoria),
    integer(Ano),
    autor(Autor, _),
    \+ livro(Titulo, _, _, _),
    assertz(livro(Titulo, Autor, Ano, Categoria)).

emprestar_livro(Titulo, Identificador, Data) :-
    texto_valido(Titulo), integer(Identificador),
    data_valida(Data),
    pessoa(_, Identificador),
    disponivel(Titulo),
    assertz(emprestado(Titulo, Identificador, Data)).

devolver_livro(Titulo) :-
    texto_valido(Titulo),
    retract(emprestado(Titulo, _, _)).

data_valida(Data) :-
    atom(Data),
    atom_codes(Data, [A,B,C,D,45,E,F,45,G,H]),
    maplist(digito, [A,B,C,D,E,F,G,H]),
    number_codes(Ano, [A,B,C,D]),
    number_codes(Mes, [E,F]),
    number_codes(Dia, [G,H]),
    Ano > 0, between(1, 12, Mes),
    dias_no_mes(Ano, Mes, Limite),
    between(1, Limite, Dia).

digito(Codigo) :- between(48, 57, Codigo).

bissexto(Ano) :-
    (0 is Ano mod 400 ; 0 is Ano mod 4, Ano mod 100 =\= 0).

dias_no_mes(Ano, 2, Dias) :-
    !, (bissexto(Ano) -> Dias = 29 ; Dias = 28).
dias_no_mes(_, Mes, Dias) :-
    (memberchk(Mes, [4,6,9,11]) -> Dias = 30 ; Dias = 31).

/* Interface: textos sem aspas e sem ponto final; numeros em linhas proprias.
 * A leitura de linhas evita interpretar a entrada como codigo Prolog.
 */
iniciar :-
    writeln('Biblioteca pessoal'),
    catch(menu, fim_da_entrada, writeln('\nAte logo!')).

menu :-
    nl,
    writeln('1 - Listar livros'),
    writeln('2 - Consultar livros por autor'),
    writeln('3 - Consultar livros antigos'),
    writeln('4 - Listar livros disponiveis'),
    writeln('5 - Consultar emprestimos por pessoa'),
    writeln('6 - Inserir livro'),
    writeln('7 - Emprestar livro'),
    writeln('8 - Devolver livro'),
    writeln('9 - Cadastrar autor'),
    writeln('10 - Cadastrar pessoa'),
    writeln('11 - Listar pessoas'),
    writeln('12 - Listar autores'),
    writeln('0 - Sair'),
    ler_texto('Opcao: ', Opcao),
    ( Opcao == '0' -> writeln('Ate logo!')
    ; (executar(Opcao) -> true ; writeln('Operacao recusada. Confira os dados informados.')),
      menu
    ).

ler_texto(Prompt, Texto) :-
    write(Prompt), flush_output,
    read_line_to_string(user_input, Linha),
    ( Linha == end_of_file -> throw(fim_da_entrada)
    ; normalize_space(atom(Texto), Linha)
    ).

ler_inteiro(Prompt, Numero) :-
    ler_texto(Prompt, Texto),
    catch(atom_number(Texto, Numero), _, fail),
    integer(Numero).

mostrar_titulos(Titulos) :-
    ( Titulos == [] -> writeln('Nenhum livro encontrado.')
    ; forall(member(Titulo, Titulos), format('  ~a~n', [Titulo]))
    ).

executar('1') :-
    forall(livro(T,A,N,C), format('~a | ~a | ~d | ~a~n', [T,A,N,C])).
executar('2') :-
    ler_texto('Autor: ', Autor),
    findall(T, livros_por_autor(Autor,T), Titulos), mostrar_titulos(Titulos).
executar('3') :-
    ler_inteiro('Ano maximo (inclusive): ', Ano),
    findall(T, livros_antigos(Ano,T), Titulos), mostrar_titulos(Titulos).
executar('4') :-
    findall(T, disponivel(T), Titulos), mostrar_titulos(Titulos).
executar('5') :-
    ler_texto('Nome da pessoa: ', Nome),
    findall(T, livros_emprestados_por(Nome,T), Titulos), mostrar_titulos(Titulos).
executar('6') :-
    ler_texto('Titulo: ', T), ler_texto('Autor cadastrado: ', A),
    ler_inteiro('Ano: ', N), ler_texto('Categoria: ', C),
    inserir_livro(T,A,N,C), writeln('Livro inserido.').
executar('7') :-
    ler_texto('Titulo: ', T), ler_inteiro('Identificador da pessoa: ', Id),
    ler_texto('Data (AAAA-MM-DD): ', Data),
    emprestar_livro(T,Id,Data), writeln('Emprestimo registrado.').
executar('8') :-
    ler_texto('Titulo: ', T), devolver_livro(T), writeln('Livro devolvido.').
executar('9') :-
    ler_texto('Nome do autor: ', N), ler_texto('Nacionalidade: ', P),
    cadastrar_autor(N,P), writeln('Autor cadastrado.').
executar('10') :-
    ler_texto('Nome da pessoa: ', N), ler_inteiro('Identificador: ', Id),
    cadastrar_pessoa(N,Id), writeln('Pessoa cadastrada.').
executar('11') :-
    forall(pessoa(N,Id), format('~d | ~a~n', [Id,N])).
executar('12') :-
    forall(autor(N,P), format('~a | ~a~n', [N,P])).
