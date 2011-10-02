ABOUT
=====

Веб игра

DOCUMENTATION
=============

https://github.com/vkevroletin/web-game-doc

WORKFLOW
========

Скоро это станет выглядеть более осмысленно.

На данный моменты приняты следующие решения:
 
* ЯП реализации: Perl
* используется middleware Plack, а не конкретный веб сервер
* фреймворк для работы с БД: KiokuDB
* никакого генерирования javascript и html в коде: для клиента 
используются шаблоны на Mason2

Код документируется, используя язык разметки POD( см. http://perldoc.perl.org/perlpod.html, http://perldoc.perl.org/perlpodstyle.html).
Для просмотра можно использовать, к примеру, утилиту perldoc, редактор emacs.

INSTALLATION
============

Установить perl. Для установки модулей рекомендую вместо дефолтного менеджера пакетов cpan использовать App::cpanminus.
Установить Plack.
Для запуска сервера, идущего в коробке с Plack, в режиме перезапуска 
после любых изменений в проекте сделать
make
Для удаления базы данных
    make remove_db

По умолчанию plackup запускает сервер на порту 5000.
Так что любоваться результатом так: `localhost:5000`
                             и так: `localhost:5000/engine`


DEPLOYMENT
========== 

Необходимо подключить Plack::Middleware::HTTPExceptions plack middleware вместо Plack::Middleware::StackTrace, используемого по дефолту, чтобы stack trace не 
доходил до пльзователя.
