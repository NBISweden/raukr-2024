import pandas          as pd
import sqlalchemy

from sqlalchemy        import and_, func
from model             import  *
from sqlalchemy.orm    import Session

# Connect to 
Base.metadata.create_all(engine)
session = Session(engine)


def get_actors(movie):
  """ Get all actors for a specific movie """
  movies    = session.query(Movie).filter(Movie.primaryTitle.like('%'+movie+'%'))
  moviedict = {}
  for movie in movies:
    moviedict[str(movie)] = movie.get_actors()
  session.close()
  return moviedict


def get_movies(actor):
  """ Get all movies for a specific actor """
  actors    = session.query(Actor).filter(Actor.primaryName.like('%'+actor+'%'))
  actordict = {}
  for actor in actors:
    actordict[str(actor)] = actor.get_movies()
  return actordict


def print_movie_info(movie):
  movies = session.query(Movie).filter(Movie.primaryTitle.like('%'+movie+'%'))
  for movie in movies:
    print('Title: ', movie.primaryTitle)
    print('Year: ', movie.startYear)
    print('Runtime (min): ', movie.runtimeMinutes)
    print('Genres: ', movie.genres)
    print('Average rating: ', movie.averageRating)
    print('Number of votes: ', movie.numVotes, '\n')
    

def get_all_movies(fromYear = False, toYear = False):
  """ Get all movies between specified years with fromYear and/or toYear """
  if fromYear:
    if toYear:
      movies = pd.read_sql(session.query(Movie).filter(and_(Movie.startYear >= fromYear),
                                                           (Movie.startYear <= toYear)
                                                      ).statement, session.bind)
    else:
      movies = pd.read_sql(session.query(Movie).filter(Movie.startYear >= fromYear
                                                      ).statement, session.bind)
  else:
    if toYear:
      movies = pd.read_sql(session.query(Movie).filter(Movie.startYear <= toYear
                                                      ).statement, session.bind)
    else:
      movies = pd.read_sql(session.query(Movie).filter(Movie.startYear
                                                      ).statement, session.bind)

  return movies


def check_results(overlap, actor1, actor2):
  """ Checks results from overlapping actors """
  overlap_actors = session.query(Actor).filter(Actor.primaryName.like('%'+overlap+'%'))
  overlapdict    = {}
  for actor in overlap_actors:
    overlapdict[actor.primaryName] = actor.get_movies()
  
  actor1_actors = session.query(Actor).filter(Actor.primaryName.like('%'+actor1+'%'))
  actor1dict    = {}
  for actor in actor1_actors:
    actor1dict[actor.primaryName] = actor.get_movies()
    
  actor2_actors = session.query(Actor).filter(Actor.primaryName.like('%'+actor2+'%'))
  actor2dict    = {}
  for actor in actor2_actors:
    actor2dict[actor.primaryName] = actor.get_movies()
  
  hits = []
  
  if len(overlapdict) == 1 and len(actor1dict) == 1 and len(actor2dict) == 1:
    overlap_set = set(overlapdict[overlap])
    actor1_set  = set(actor1dict[actor1])
    actor2_set  = set(actor2dict[actor2])
    act1_diff   = actor2_set - actor1_set
    act2_diff   = actor1_set - actor2_set
    
    res_int1    = act1_diff.intersection(overlap_set)
    res_int2    = act2_diff.intersection(overlap_set)
    if res_int1 and res_int2:
      for movie in res_int1:
        hits.append("{} ({})".format(movie, actor2))
      for movie in res_int2:
        hits.append("{} ({})".format(movie, actor1))
    else:
      print('No actor found', movie)
  if hits:
    print('Correct!')
  else:
    print('Not correct, try again')
  return hits

