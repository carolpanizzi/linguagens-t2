# Biblioteca pessoal em Prolog

Autores: Carolina Panizzi, Isabella Zarosa e Paulo Trevisan

Implementação do Trabalho 2 em um único arquivo de entrega: `biblioteca_pessoal.pl`.

Com o SWI-Prolog instalado, execute:

```sh
swipl -s biblioteca_pessoal.pl
```

No interpretador, abra a interface textual do bônus:

```prolog
?- iniciar.
```

O menu aceita textos sem aspas nem ponto final. Para consultas diretamente no
interpretador, use a sintaxe Prolog, incluindo aspas em textos e ponto final.

```prolog
?- livros_por_autor('Machado de Assis', Titulo).
?- livros_antigos(1900, Titulo).
?- disponivel(Titulo).
?- livros_emprestados_por('Maria Silva', Titulo).
?- inserir_livro('Memorial de Aires', 'Machado de Assis', 1908, 'Romance').
?- emprestar_livro('Dom Casmurro', 103, '2026-11-03').
?- devolver_livro('Dom Casmurro').
```

Use `;` para obter outras soluções de uma consulta. Use `halt.` para sair.

A base inicial contém seis livros, quatro autores, três pessoas e dois
empréstimos. O título identifica um exemplar único. Autores precisam estar
cadastrados antes da inserção de livros; o menu permite cadastrar autores e
pessoas. Datas seguem `AAAA-MM-DD` e são verificadas pelo calendário, incluindo
anos bissextos. Anos de publicação são inteiros; valores negativos representam
anos antes de Cristo.

Operações inválidas falham sem modificar a base: títulos repetidos, autores ou
pessoas inexistentes, datas inválidas, empréstimo de livro indisponível ou
devolução de livro sem empréstimo. As alterações ficam em memória durante a
sessão; não há persistência automática em disco.

