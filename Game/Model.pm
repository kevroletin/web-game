package Game::Model;
use strict;
use warnings;

use KiokuDB;
use KiokuDB::Backend::DBI;
use KiokuDB::Backend::BDB;
use KiokuDB::Backend::BDB::GIN;
use Search::GIN::Extract::Callback;

use Game::Environment qw(:std :db);


my @extractors;

sub _all_extractors {
    my ($obj, $extractor, @args) = @_;
    my $ans = {};
    for (@extractors) {
        $_->($ans, @_)
    }
    $ans->{CLASS} = ref($obj);
    $ans
}

sub add_extractor {
    push @extractors, $_ for @_
}

sub create_extractor {
    no strict 'refs';
    my ($class) = @_;

    my @fields = @{"${class}::db_index"};
    sub {
        my ($h, $obj, $extractor, @args) = @_;
        return unless ref($obj) eq $class;
        for (@fields) {
            # method call. How to write it better?
            $h->{$_} = &{"${class}::$_"}($obj)
        }
    }
}

sub _register_default_extractors {
    for (qw(Game::Model::Counter
            Game::Model::Game
            Game::Model::Map
            Game::Model::User)){
        add_extractor(create_extractor($_))
    }
}

sub connect_db {
    _register_default_extractors();
    my $dir = KiokuDB->new(
# Search::Gin queries with intersection doesn't work
#      backend => KiokuDB::Backend::BDB::GIN->new(
#          manager => {
#               home => "tmp/db",
#               create => 1,
#               transactions => 0
#          },
#          extract => Search::GIN::Extract::Callback->new(
#              extract => \&_all_extractors
#          )
#      ),

       backend => KiokuDB::Backend::DBI->new({
            create => 1,
            dsn => 'dbi:SQLite:dbname=tmp/test.db',
            extract => Search::GIN::Extract::Callback->new(
                extract => \&_all_extractors
            ),
        })
    );
    db($dir);
    db_scope($dir->new_scope());
}

1

__END__

=head1 NAME

Game::Model - соединение с базой данных, регистрация экстракторов

=head1 DESCRIPTION

Используемый фреймворк для работы с базой данных: L<KiokuDB>.
L<KiokuDB> позволяет сохранять в базе данных структуры данных
Perl. Перед отправкой в БД объект сериализуется, т.е. перводится
в представление пригодное для его сохранения в БД, и, что самое
главное пригодное для его последующей загрузки.
Для простых структур данных
есть сериализатор по умолчанию. Так же объекты созданные при
помощи L<Moose> могут быть сохранены без указания сериализатора.

Все объекты сохранятся в одной таблице с 2мя полями: id объекта
и, собственно, сериализованный объект. В данном подходе есть
недостаток: плохо(если вообще) работает поик. Для решения этой
проблемы есть 2 подхода:

=over

=item 1
Создавать дополнительные поля в таблице
(на данный момент созданы поля name и сид). Недостаткоя является то,
что для большинства объектов выделенные поля будут пустыми.

=item 2
Отдельно поддержить информация о объектах, хранящихся в БД. Такой подход
реализован в библиотеке, но
не задокументирован. Так что для его реализации прийдётся использовать
другой интерфейс к базе данных и вручную поддерживать эту информацию.

=back

=head1 METHODS

=head2 connect_db

Читает конфиг из config/db.yml и устанавливает соединение.

=cut
