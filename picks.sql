select 'HOME', u.name, p.points, t.city, t.nickname
  from users u, weeks w, entries e, picks p, games g, teams t
 where w.week_num = 16 
   and u.name = 'diamondgirl'
   and e.user_id = u.id
   and e.week_id = w.id
   and p.pick = 'HOME'
   and p.entry_id = e.id
   and g.id = p.game_id
   and t.id = g.home_team_id
union
select 'AWAY', u.name, p.points, t.city, t.nickname
  from users u, weeks w, entries e, picks p, games g, teams t
 where w.week_num = 16 
   and u.name = 'diamondgirl'
   and e.user_id = u.id
   and e.week_id = w.id
   and p.pick = 'AWAY'
   and p.entry_id = e.id
   and g.id = p.game_id
   and t.id = g.home_team_id
order by 3,1
;
