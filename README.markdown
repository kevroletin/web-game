ABOUT
=====

Веб игра

DOCUMENTATION
=============

!Внимание: документация плохо поддерживается и местами не соответствует
текущей реализации.
https://github.com/vkevroletin/web-game-doc

WORKFLOW
========

Общие детали реализации
 
* ЯП реализации: Perl
* используется middleware Plack, а не конкретный веб сервер
* фреймворк для работы с БД: KiokuDB

!Внимание, документация устарела и не обновлялась долгое время.
Код документируется, используя язык разметки POD( см. http://perldoc.perl.org/perlpod.html, http://perldoc.perl.org/perlpodstyle.html).
Для просмотра можно использовать, к примеру, утилиту perldoc, редактор emacs.

INSTALLATION
============

1) `mkdir tmp`

2) Установить perl.
-Список необходимых модулей смотрите в файле DEPENDENCIES-
`cpan DBI DBD::SQLite Task::Plack Task::Moose Task::KiokuDB Exporter::Easy Data::Dumper::Concise`


Для запуска сервера выполнить в корне проекта команду
    make
Для удаления базы данных
    make remove_db

По умолчанию plackup запускает сервер на порту 5000.
Так что любоваться результатом так:
    localhost:5000 - клиент
    localhost:5000/engine - сервер


RUN TESTS
=========

    cd t
    perl all.t

Логи тестирования находятся в файлах *.log и *.msg

DEPLOYMENT
========== 

Необходимо подключить Plack::Middleware::HTTPExceptions plack middleware вместо Plack::Middleware::StackTrace, используемого по дефолту, чтобы stack trace не 
доходил до пльзователя.
