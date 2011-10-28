package Game::Roles::Race;
use Moose::Role;


requires 'race_name';
requires 'tokens_cnt';
requires 'check_is_move_possible';
requires 'conquer';
requires 'compute_tokens';


1
