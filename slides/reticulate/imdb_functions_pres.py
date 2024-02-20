import pandas          as pd
import sqlalchemy

from sqlalchemy        import and_, func
from model_pres        import  *
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



