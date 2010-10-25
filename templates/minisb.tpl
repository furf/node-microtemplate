<%

  var dt    = bam.datetime,
      today = new Date(this.date),
      yday  = dt.DateTime(new Date(today)).incrementDate(-1),
      year  = today.getFullYear(),
      nHasProbables = 0;

  if (this.gamesByType.R) {
    regularSeasonGames(this.gamesByType.R);
  }

  if (this.postseasonGames) {
    postseasonGames(this.postseasonGames, this.postseasonMode, this.worldSeriesSchedule);
  }

%>
<%

  function regularSeasonGames (games) {

%>
<div class="sb rs">
  <div class="hd">
    <span class="today"><%= dt.getDayFullName(today.getDay() + 1) %></span>
    <a href="/mlb/scoreboard/#date=<%= yday.toShortDate() %>" class="yesterday"><%= dt.getDayName(yday.getDay() + 1) %> Scores &raquo;</a>
  </div>
  <div class="bd">
    <ul class="games">
    <%

      var i = 0, n = games.length;

      for (; i < n; ++i) {
        regularSeasonGame(games[i]);
      }

    %>
    </ul>
  </div>
  <div class="ft">
    <% if (nHasProbables > 0) { %>
      <a href="/news/probable_pitchers/?tcid=mm_mlb_news" class="link_to_proabables">Probable Pitchers &raquo;</a>
    <% } %>
    <span class="et">All times ET</span>
  </div>
</div>
<% } %>
<%

  function regularSeasonGame (g) {

    var s     = g.status,
        type  = g.type,
        r     = g.linescore && g.linescore.r,
        a     = g.teams.away,
        h     = g.teams.home,
        links = g.links,
        hasAwayProbable = a.probable_pitcher && a.probable_pitcher.last,
        hasHomeProbable = h.probable_pitcher && h.probable_pitcher.last,
        hasProbables    = hasAwayProbable || hasHomeProbable;

    if (hasProbables) {
      nHasProbables++;
    }

%>
<%

  function linescore () {

%>
<table class="linescore">
  <tbody>
    <%

      linescoreRow("away");
      linescoreRow("home");

    %>
  </tbody>
</table>
<% } %>
<%

  function linescoreRow (ha) {

    var t = g.teams[ha];
%>
<tr class="<%= t === g.teams.winning ? "winner" : t === g.teams.losing ? "loser" : "" %>">
  <th class="club"><%= t.name_abbrev %></th>
  <% if (!s.is_pre_game) { %>
    <td class="runs"><%= r && r[ha] || "-" %></td>
  <% } %>
</tr>
<% } %>
<%

  function gamedayButton () {

%>
<a href="<%= links.gameday %>" class="gameday<%= s.is_scheduled && hasProbables ? " hasProbables" : "" %>" title="Gameday">
  <span class="icon">Gameday</span>
  <%

    linescore();

    if (s.is_scheduled) {

      gameTime();

      if (hasProbables) {
        probables();
      };

    } else if (s.is_pre_game) {

      gameTime();

    } else if (g.has_resumption) {

      status();

    } else if (g.is_resumption) {

      status();
      gameTime();

    } else if (s.is_warmup || s.is_delayed_start || s.is_in_progress || s.is_delayed) {

      status();

    }
  %>
</a>
<% } %>
<%

  function audioButton () {

%>
<a href="<%= links.atbat %>" class="atbat" title="Listen to At Bat/Audio">
  <span class="icon">At Bat</span>
</a>
<% } %>
<%

  function videoButton () {

%>
<% if (links.mlbtv) { %>
  <a href="<%= links.mlbtv %>" class="mlbtv" title="Watch on MLB.TV">
<% } else { %>
  <a href="<%= links.buyMLBTV %>" class="mlbtv" title="Buy MLB.TV">
<% } %>
    <span class="icon">MLB.TV</span>
  </a>
<% } %>
<%

  function ticketsButton () {

    /* @todo replace anchor with a span and replace when ticket data is loaded */
%>
<a href="javascript:void(0);return false;" class="tickets disabled" id="tickets-<%= g.game_pk %>">
  <span class="icon">Tickets</span>
</a>
<% } %>
<%

  function wrapButton () {

%>
<a href="<%= links.wrap %>" class="wrap" title="Wrap">
  <%

    linescore();
    finalStatus();

  %>
  <span class="label">Wrap</span>
</a>
<% } %>
<%

  function boxButton () {

%>
<a href="<%= links.boxscore %>" class="box" title="Boxscore">
  <span class="label">Box</span>
</a>
<% } %>
<%

  function nixedButton () {

%>
<a href="<%= links.boxscore %>" class="nixed" title="">
  <% linescore() %>
  <div class="status" title="<%= s.status + (s.reason ? ": " + s.reason : "") %>">
    <div class="summary"><%= s.status %></div>
    <% if (s.reason) { %>
      <div class="detail"><%= s.reason %></div>
    <% }  %>
  </div>
</a>
<% } %>
<%

  function finalStatus () {

    var inn = s.inning !== g.scheduled_innings ? "/" + s.inning : "";

%>
<div class="status" title="Final<%= inn %>">F<%= inn %></div>
<% } %>
<%

  function status () {

%>
<div class="status">
  <% inning() %>
  <% summary() %>
</div>
<% } %>
<%

  function inning () {

    var ord   = $.ordinal(s.inning),
        cn    = s.is_top_of_inning ? "top" : "bottom",
        text  = (s.is_top_of_inning ? "Top" : "Bottom") + " of the ",
        title = text + s.inning + ord;

%>
<div class="inning" title="<%= title %>">
  <span class="half <%= cn %>"><%= text %></span> <%= s.inning %><span class="ordinal"><%= ord %></span>
</div>
<% } %>
<%

  function summary () {

%>
<% if (!s.is_in_progress) { %>
  <div class="summary" title="<%= s.status + (s.reason ? ": " + s.reason : "") %>">
    <%= (s.is_delayed || s.is_delayed_start) && "Delay" || s.is_suspended && "Susp" || s.status %>
  </div>
<% } %>
<% } %>
<%

  function probables () {

%>
<div class="probables">
  <table>
    <tbody>
      <%
        hasAwayProbable && probablesRow(a);
        hasHomeProbable && probablesRow(h);
      %>
    </tbody>
  </table>
</div>
<% } %>
<%

  function probablesRow (t) {

    var p = t.probable_pitcher;
%>
<tr>
  <th class="club"><%= t.name_abbrev %></th>
  <td class="probable"><%= p.last %> (<%= p.wins %>-<%= p.losses %>)</td>
</tr>
<% } %>
<%

  function gameTime () {

%>
<div class="time">
  <% if (g.is_tbd) { %>
    <% if (g.is_doubleheader) { %>
      <span class="doubleheader">Gm <%= g.game_number %></span>
    <% } else { %>
      <span class="tbd">TBD</span>
    <% } %>
  <% } else { %>
    <span class="time"><%= g.time %> <%= g.ampm %></span>
  <% } %>
</div>
<% } %>
<li class="game <%= s.status.replace(/\W/g, "").toLowerCase() %> <%= s.epg %><% if (g.is_resumption) { %> is_resumption<% } else if (g.has_resumption) { %> has_resumption<% } %>">
  <div class="buttons">
    <%

      /* Basic button layout */

      if (s.is_scheduled) {

        gamedayButton();
        ticketsButton();

      } else if (s.is_pre_game) {

        gamedayButton();
        audioButton();

        if (links.mlbtv) {
          videoButton();
        } else {
          ticketsButton();
        }

      } else if (s.is_warmup || s.is_delayed_start || s.is_in_progress || s.is_delayed) {

        gamedayButton();
        audioButton();
        videoButton();

      } else if (s.is_over || s.is_final || s.is_completed_early) {

        wrapButton();
        boxButton();

      } else if (s.is_suspended) {

        /* @todo -- need to refactor non-gameday states out of catch-all gamedayButton */
        gamedayButton();

        if (!g.is_resumption) {
          boxButton();
        }

      } else if (s.is_nixed || s.is_forfeit) {

        nixedButton();

      }

    %>
  </div>
</li>
<% } %>





<% /*====================================================================*/ %>

<%

  function postseasonGames (games, mode, worldSeriesSchedule) {

%>
<div class="sb ps <%= mode %>">
  <div class="hd">
    <h1><a href="http://worldseries.com/"><%= today.getFullYear() + (mode === "ws" ? " World Series" : " Postseason") %></a></h1>
  </div>
  <div class="bd">
    <ul class="games">
    <%

      var i = 0, n = games.length, g;

      for (; i < n; ++i) {
        g = games[i];
        if (g.postseason.message.enabled === "true" && g.postseason.message.blurb) {
          postseasonEditorial(g);
        } else {
          postseasonGame(g);
        }
      }

    %>
    </ul>
    <%

      if (worldSeriesSchedule) {
        fullSchedule(worldSeriesSchedule);
      }
      
    %>
  </div>
</div>
<% } %>
<%

  function seriesHeader (g) {
%><h2><%= year %> <%= g.postseason.round %></h2><% } %>

<% 

  function postseasonEditorial (g) {
    
    var ps    = g.postseason,
        cn    = (ps.series.substr(-2) + " " + ps.series).toLowerCase(),
        msg   = ps.message,
        num   = ps.game.number,
        blurb = msg.blurb,
        link  = msg.link,
        date  = msg.date,
        time  = msg.time,
        away  = msg.away && msg.away.toLowerCase(),
        home  = msg.home && msg.home.toLowerCase();
%>
<li class="editorial <%= cn %>">
  <% seriesHeader(g) %>
  <div class="message">
    <div class="blurb">

      <table>
        <tbody>
          <tr>
            <td class="away">
              <% if (!g.type.is_world_series && away && away !== "tbd") { %>
                <img src="/flash/scoreboard/y2010/postseason/logos/<%= away %>.png" class="away">
              <% } %>
            </td>
            <td>
              <% if (link) { %>
                <a href="<%= link %>"><%= blurb %></a>
              <% } else { %>
                <%= blurb %>
              <% } %>
            </td>
            <td class="home">
              <% if (!g.type.is_world_series && home && home !== "tbd") { %>
                <img src="/flash/scoreboard/y2010/postseason/logos/<%= home %>.png" class="home">
              <% } %>
            </td>
          </tr>
        </tbody>
      </table>
      
    </div>
    <% if (num) { %><div class="num">Game <%= num %></div><% } %>
    <% if (date || time) { %>
      <div class="datetime">
        <% if (date) { %><div class="date"><%= date %></div><% } %>
        <% if (time) { %><div class="time"><%= time %></div><% } %>
      </div>
    <% } %>
  </div>
</li>
<% } %>
<% 

  function postseasonGame (g) {

    var s     = g.status,
        type  = g.type,
        r     = g.linescore && g.linescore.r,
        a     = g.teams.away,
        h     = g.teams.home,
        links = g.links,
        hasAwayProbable = a.probable_pitcher && a.probable_pitcher.last,
        hasHomeProbable = h.probable_pitcher && h.probable_pitcher.last,
        hasProbables    = hasAwayProbable || hasHomeProbable,
        thumbWidth,
        thumbHeight,
        postseasonClassName = "";
    
    if (g.game_type === "D") {

      postseasonClassName = " ds " + (g.league === "NN" ? "nlds" : "alds");

    } else if (g.game_type === "L") {

      postseasonClassName = " cs " + (g.league === "NN" ? "nlcs" : "alcs");

      thumbWidth  = 43;
      thumbHeight = 52;
      
    } else if (g.game_type === "W") {

      postseasonClassName = " ws";

      thumbWidth  = 62;
      thumbHeight = 75;
    }
  
%>
<li class="game <%= s.status.replace(/\W/g, "").toLowerCase() %> <%= s.epg %><% if (g.is_resumption) { %> is_resumption<% } else if (g.has_resumption) { %> has_resumption<% } %><%= postseasonClassName %>">
  <%

    if (g.game_type === "D" || g.game_type === "L") {
      seriesHeader(g);
    }

    seriesRecord();
    gameInfo();
    
    if (s.is_suspended) {
      if (s.is_resumption) {
        psProbables();
      } else {
        psPitcherBatter();
      }
    } else if (s.is_before_game && hasProbables) {
      psProbables();
    } else if (s.is_during_game) {
      psPitcherBatter();
    } else if (s.is_after_game) {
      psWinnerLoser();
    }

    mediaButtons();

    if (!g.type.is_world_series) {
      fullSeriesButton();
    }

  %>
</li>
<%
  
  function seriesRecord () {

    var leading  = g.series.leading,
        homeTeam = g.series.home,
        verb     = leading && (g.type.is_division_series && leading.win === "3" || leading.win === "4") ? "wins" : "leads";
        override = g.postseason.status_override,
        away     = a.name_abbrev.toLowerCase(),
        home     = h.name_abbrev.toLowerCase(),
        series   = g.series.series;
        
%>
<div class="record">
  
  <table>
    <tbody>
      <tr>
        <% if (!g.type.is_world_series) { %>
          <td class="away">
            <% if (away !== "tbd") { %>
              <img src="/flash/scoreboard/y2010/postseason/logos/<%= away %>.png" class="away">
            <% } %>
          </td>
        <% } %>
        <td>
          <% if (override) { %>
              <%= override %>
          <% } else if (leading) { %>
            <%= leading.name_abbrev %> <%= verb %> <%= series %> <%= leading.win %>-<%= leading.loss %>
          <% } else if (+homeTeam.win) { %>
            <%= series %> tied <%= homeTeam.win %>-<%= homeTeam.loss %>
          <% } else if (s.is_before_game) { %>
            <%= series %> begins <%= dt.formatDate(new Date(g.current_date), "MMM. d") %>
          <% } %>
        </td>
        <% if (!g.type.is_world_series) { %>
          <td class="home">
            <% if (home !== "tbd") { %>
              <img src="/flash/scoreboard/y2010/postseason/logos/<%= home %>.png" class="away">
            <% } %>
          </td>
        <% } %>
      </tr>
    </tbody>
  </table>
  
</div>
<% } %>
<% 

  function gameInfo () {
    
    var ps   = g.postseason,
        num  = ps.game.number,
        msg  = ps.message,
        date = msg.date,
        time = msg.time;

%>
<div class="gameInfo">
  <div class="num">Game <%= num %></div>
  <%
    
    linescore();
    statusWrap();
    
  %>
</div>
<% } %>
<%

  function linescore () {

%>
<table class="linescore">
  <tbody>
    <%

      linescoreRow("away");
      linescoreRow("home");

    %>
  </tbody>
</table>
<% } %>
<%

  function linescoreRow (ha) {

    var t = g.teams[ha];
%>
<tr class="<%= t === g.teams.winning ? "winner" : t === g.teams.losing ? "loser" : "" %>">
  <th class="club"><%= t.name_abbrev %></th>
  <% if (!s.is_pre_game) { %>
    <td class="runs"><%= r && r[ha] || "" %></td>
  <% } %>
</tr>
<% } %>
<% 

  function statusWrap () {

%>
<div class="status">
  <% 
    
    if (s.is_scheduled || s.is_pre_game) {

      gameTime();

    } else if (g.is_resumption) {

      gameTime();
      summary();

    } else if (s.is_warmup || s.is_delayed_start || s.is_in_progress || s.is_delayed || s.is_suspended) {

      inning();
      summary();

    } else if (s.is_over || s.is_final || s.is_completed_early) {
      
      finalStatus();
      
    } else if (s.is_nixed || s.is_forfeit) {
      
      summary();
      
    }

  %>
</div>
<% } %>

<%

  function inning () {

    var ord   = $.ordinal(s.inning),
        cn    = s.is_top_of_inning ? "top" : "bottom",
        text  = (s.is_top_of_inning ? "Top" : "Bottom") + " of the ",
        title = text + s.inning + ord;

%>
<div class="inning" title="<%= title %>">
  <span class="half <%= cn %>"><%= text %></span> <%= s.inning %><span class="ordinal"><%= ord %></span>
</div>
<% } %>
<%

  function summary () {

%>
<% if (!s.is_in_progress) { %>
  <div class="summary" title="<%= s.status + (s.reason ? ": " + s.reason : "") %>">
    <%= (s.is_delayed || s.is_delayed_start) && "Delay" || s.is_suspended && "Susp" || s.status %>
  </div>
<% } %>
<% } %>
<%

  function gameTime () {

%>
<div class="time">
  <% if (g.is_tbd) { %>
    <% if (g.is_doubleheader) { %>
      <span class="doubleheader">Gm <%= g.game_number %></span>
    <% } else { %>
      <span class="tbd">TBD</span>
    <% } %>
  <% } else { %>
    <span class="date"><%= bam.datetime.formatDate(g.current_date, "MMM. d") %></span>
    <span class="time"><%= g.time %> <%= g.ampm %></span>
  <% } %>
</div>
<% } %>
<%

  function finalStatus () {

    var inn = s.inning !== g.scheduled_innings ? "/" + s.inning : "";

%>
<span class="final" title="Final<%= inn %>">F<%= inn %></span>
<% } %>
<% 
  
  function psProbables () {
    
%>
<div class="keyPlayers">

  <% if (type.is_division_series) { %>

    <dl class="probables">
      <dt><% teamAbbrev(a) %>:</dt>
      <dd><% if (hasAwayProbable) { %><% pitcherLink(a.probable_pitcher, type.is_pre_season) %><% } else { %>TBD<% } %></dd>
      <dt><% teamAbbrev(h) %>:</dt>
      <dd><% if (hasHomeProbable) { %><% pitcherLink(h.probable_pitcher, type.is_pre_season) %><% } else { %>TBD<% } %></dd>
    </dl>

  <% } else { %>

    <% if (hasAwayProbable) { %>
      <div class="awayProbable">
        <img src="http://gdx.mlb.com/images/gameday/mugshots/mlb/<%= a.probable_pitcher.id %>.jpg" width="<%= thumbWidth %>" height="<%= thumbHeight %>">
        
        <span class="caption">
          <% playerLink(a.probable_pitcher) %>
        </span>
      </div>
    <% } %>

    <% if (hasHomeProbable) { %>
      <div class="homeProbable">
        <img src="http://gdx.mlb.com/images/gameday/mugshots/mlb/<%= h.probable_pitcher.id %>.jpg" width="<%= thumbWidth %>" height="<%= thumbHeight %>">
        <span class="caption">
          <% playerLink(h.probable_pitcher) %>
        </span>
      </div>
    <% } %>

  <% } %>

</div>
<% } %>
<% 
  
  function psPitcherBatter () {

%>
  <% if (g.pitcher || g.batter) { %>
    <div class="keyPlayers">

      <% if (type.is_division_series) { %>
      
        <dl class="pitcherBatter">

          <% if (g.pitcher) { %>
            <dt><abbr title="Pitching">P:</abbr></dt>
            <dd><% pitcherBatter(g.pitcher) %></dd>
          <% } %>

          <% if (g.batter) { %>
            <dt><abbr title="Batting">B:</abbr></dt>
            <dd><% pitcherBatter(g.batter) %></dd>
          <% } %>

        </dl>

      <% } else { %>

        <% if (g.pitcher) { %>
          <div class="pitcher">
            <img src="http://gdx.mlb.com/images/gameday/mugshots/mlb/<%= g.pitcher.id %>.jpg" width="<%= thumbWidth %>" height="<%= thumbHeight %>">
            <span class="caption">
              <abbr title="Pitching">P:</abbr> <% playerLink(g.pitcher) %>
            </span>
          </div>
        <% } %>

        <% if (g.batter) { %>
          <div class="batter">
            <img src="http://gdx.mlb.com/images/gameday/mugshots/mlb/<%= g.batter.id %>.jpg" width="<%= thumbWidth %>" height="<%= thumbHeight %>">
            <span class="caption">
              <abbr title="Batting">B:</abbr> <% playerLink(g.batter) %>
            </span>
          </div>
        <% } %>

      <% } %>
      
    </div>
  <% } %>
<% } %>
<% 
  
  function psWinnerLoser () {
  
    var winningPitcher    = g.winning_pitcher,
        losingPitcher     = g.losing_pitcher,
        hasWinningPitcher = (typeof winningPitcher !== "undefined" && winningPitcher.id !== ""),
        hasLosingPitcher  = (typeof losingPitcher !== "undefined" && losingPitcher.id !== "");
    
%>
  <% if (hasWinningPitcher || hasLosingPitcher) { %>
    <div class="keyPlayers">
      
      <% if (type.is_division_series) { %>
      
        <dl class="winnerLoser">
          
          <% if (hasWinningPitcher) { %>
            <dt><abbr title="Winning Pitcher">W:</abbr></dt>
            <dd><% pitcherLink(winningPitcher) %></dd>
          <% } %>

          <% if (hasLosingPitcher) { %>
            <dt><abbr title="Losing Pitcher">L:</abbr></dt>
            <dd><% pitcherLink(losingPitcher) %></dd>
          <% } %>

        </dl>
        
      <% } else { %>
      
        <% if (hasWinningPitcher) { %>
          <div class="winner">
            <img src="http://gdx.mlb.com/images/gameday/mugshots/mlb/<%= winningPitcher.id %>.jpg" width="<%= thumbWidth %>" height="<%= thumbHeight %>">
            <span class="caption">
              <abbr title="Winning Pitcher">W:</abbr> <% playerLink(winningPitcher) %>
            </span>
          </div>
        <% } %>
        
        <% if (hasLosingPitcher) { %>
          <div class="loser">
            <img src="http://gdx.mlb.com/images/gameday/mugshots/mlb/<%= losingPitcher.id %>.jpg" width="<%= thumbWidth %>" height="<%= thumbHeight %>">
            <span class="caption">
              <abbr title="Losing Pitcher">L:</abbr> <% playerLink(losingPitcher) %>
            </span>
          </div>
        <% } %>
        
      <% } %>
      
    </div>
  <% } %>
<% } %>
<%
  
  function teamAbbrev (t) {
  
%><abbr title="<%= t.team_city %>"<%= (t.split_squad) === "Y" ? " class=\"split\"": "" %> class="teamAbbrev"><%= t.name_abbrev %></abbr><% } %>
<%
  
  function playerName (p) {

%><abbr title="<%= p.first %> <%= p.last %>" class="playerName"><%= p.name_display_roster || p.last %></abbr><% } %>
<%
  
  function playerLink (p) {
    
    if (p.link) {
    
%><a href="<%= p.link %>" class="playerLink"><% playerName(p) %></a><% } else { %><% playerName(p) %><% } %><% } %>
<%
  
  function pitcherBatter (p) {
    
%><% playerLink(p) %> <span class="teamAbbrevWrap">(<% teamAbbrev(p.team) %>)</span><% } %>
<%
  
  function pitcherLink (p) {

%><% playerLink(p) %>
  <% if (g.type.is_post_season) { %>
    <% if (p.era === "-.--") { %>
      (<%= p.s_wins %>-<%= p.s_losses %>, <%= p.s_era %>)
    <% } else { %>
      (<%= p.wins %>-<%= p.losses %>, <%= p.era %>)
    <% } %>
  <% } else { %>
    (<%= p.wins %>-<%= p.losses %>, <%= p.era %>)
  <% } %>
<% } %>
<% 
  
  function mediaButtons () {
    
%>
<div class="buttons">
  <%

    /* Basic button layout */

    if (s.is_scheduled) {

      if (links.mlbtv) {
        videoButton();
      } else {
        previewVideoButton();
      }

    } else if (s.is_pre_game) {

      gamedayButton();
      audioButton();

      if (links.mlbtv) {
        videoButton();
      }

    } else if (s.is_warmup || s.is_delayed_start || s.is_in_progress || s.is_delayed) {

      gamedayButton();
      audioButton();

      if (links.mlbtv) {
        videoButton();
      }

    } else if (s.is_over || s.is_final || s.is_completed_early) {

      wrapButton();
      boxButton();

    } else if (s.is_suspended) {

      if (!g.is_resumption) {
        boxButton();
      }

    }

  %>
</div>
<% } %>
<% 

  function fullSeriesButton () {
  
%><a href="/mlb/ps/y2010/index.jsp" class="fullSeries" title="Full Series Coverage"><span class="icon">Full Series Coverage</span></a><% } %>
<%

  function ticketsButton () {

%><% } %>
<%

  function gamedayButton () {

%><a href="<%= links.gameday %>" class="gameday" title="Gameday"><span class="icon">Gameday</span></a><% } %>
<%

  function audioButton () {

%><a href="<%= links.atbat %>" class="atbat" title="Listen to At Bat/Audio"><span class="icon">At Bat</span></a><% } %>
<%

  function videoButton () {

    var href = links.mlbtv ? links.mlbtv : links.buyMLBTV,
        text = links.mlbtv ? "Watch" : "Watch Online";
        
%><a href="<%= href %>" class="mlbtv" title="<%= text %>"><span class="icon"><%= text %></span></a><% } %>
<%

  function previewVideoButton () {

    var league  = h.league_code || a.league_code,
        partner = league === "AL" && "?partner=tbs" || league === "NL" && "?partner=fox" || "",
        href    = "/mlb/subscriptions/postseason/tv.jsp" + partner,
        text    = "POSTSEASON.TV: Watch Online &raquo;";
        
%><a href="<%= href %>" class="mlbtv" title="<%= text %>"><span class="label"><%= text %></span></a><% } %>
<%

  function wrapButton () {

%><a href="<%= links.wrap %>" class="wrap" title="Wrap"><span class="label">Wrap</span></a><% } %>
<%

  function boxButton () {

%>
<a href="<%= links.boxscore %>" class="box" title="Boxscore"><span class="label">Box</span></a>
<% } %>
<% } %>

<% /*====================================================================*/ %>
<% 

  function fullSchedule (games) {

%>
<div class="fullSchedule">
  <h2>Full Schedule</h2>
  <div class="schedule">
    <table>
      <tbody>
        <% $.each(games, game) %>
      </tbody>
    </table>
  </div>
</div>
<%
  
  function game (i, g) {
    
    var away = g.away,
        home = g.home;
%>
<tr class="<%= i % 2 ? "even" : "odd" %>">
  <th class="num">GM <%= g.ser_game_nbr %><% if (!g.is_necessary) { %>*<% } %></th>
  <%

    var status = g.game && g.game.status.status || g.game_status_text;
    
    switch (status) {

      case "Scheduled":
      case "Preview":
      case "Pre-Game":
        gameTime();
        gameLocation();
      break;

      case "Warmup":
      case "Delayed Start":
      case "In Progress":
      case "Delayed":
        gameScore();
        gameEmpty();
        gameStatus(status);
      break;

      case "Game Over":
      case "Final":
      case "Completed Early":
        gameScore();
        gameStatus(status);
        gameLinks();
      break;

      case "Suspended":
        /* @todo need to detect resumption */
        if (true) {
          gameScore();
          gameEmpty();
          gameStatus(status);
        } else {
          gameTime();
          gameStatus(status);
        }
      break;

      case "Cancelled":
      case "Postponed":
      case "Forfeit":
        gameEmpty();
        gameEmpty();
        gameEmpty();
        gameStatus(status);
      break;
    }

  %>
</tr>
<% 
  
  function gameTime () {
    
%>
<td colspan="3" class="datetime date"><%= bam.datetime.formatDate(g.date, "EEE M/d") %></td>
<td colspan="3" class="datetime time"><%= bam.datetime.formatDate(g.date, "h:mmA") %></td>
<% } %>
<% 
  
  function gameLocation () {
    
%>
<td colspan="2" class="location">@<%= home.name_abbrev %></td>
<% } %>
<% 
  
  function gameScore () {

    var runsAway = $.deep(g, "game.linescore.r.away") || g.away.score,
        runsHome = $.deep(g, "game.linescore.r.home") || g.home.score;
    
%>
<td colspan="2" class="score away"><%= away.name_abbrev %> <%= runsAway %></td>
<td colspan="2" class="score home"><%= home.name_abbrev %> <%= runsHome %></td>
<% } %>
<% 
  
  function gameStatus (status) {

    var brief = {
          "In Progress":     "LIVE",
          "Final":           "F",
          "Game Over":       "F",
          "Completed Early": "F",
          "Warmup":          "WARMUP",
          "Suspended":       "SUSP",
          "Forfeit":         "FORFT",
          "Cancelled":       "CANCL",
          "Postponed":       "PPD",
          "Delayed":         "DELAY",
          "Delayed Start":   "DELAY"
        }[status],

        inning = brief === "F" && (g.game && g.game.status.inning || g.inning);
%>
<td colspan="2" class="status <%= brief.toLowerCase() %>"><%= brief %><% if (inning && inning !== "9") { %>/<%= inning %><% } %></td>
<% } %>
<% 
  
  function gameEmpty () {

%>
<td colspan="2"></td>
<% } %>
<% 
  
  function gameLinks () {
    
%>
<td colspan="2" class="links">
  <ul>
    <li class="wrap"><a href="<%= g.links.wrap %>" title="Wrap">Wrap</a></li><li class="box"><a href="<%= g.links.boxscore %>" title="Boxscore">Box</a></li>
  </ul>
</td>
<% } %>
<% } %>
<% } %>
