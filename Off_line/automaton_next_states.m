%Return number of next states; array of next states possibles and corresponding event number
function [n, next_states, events_number] = automaton_next_states(q_current)
    buff = SysHybride('get_next_id', q_current);
    events_number = find(buff > 0);
    next_states = buff(events_number);
    n = length(next_states);
end
