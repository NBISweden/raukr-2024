from sqlalchemy                   import create_engine, Column, Integer, String, Boolean, Text, Float, ForeignKey, Table, MetaData, or_, and_, func
from sqlalchemy.orm               import relationship, Session
from sqlalchemy.ext.declarative   import declarative_base

engine   = create_engine("sqlite:///imdb_pres.db")
Base     = declarative_base()


principal_movie = Table(  'principal_movie'
                        , Base.metadata
                        , Column('principal_id', Integer, ForeignKey('principal.id'))
                        , Column('movie_id', Integer, ForeignKey('movie.id'))
                        )

principal_actor = Table(  'principal_actor'
                        , Base.metadata
                        , Column('principal_id', Integer, ForeignKey('principal.id'))
                        , Column('actor_id', Integer, ForeignKey('actor.id'))
                        )

class Movie(Base):
    __tablename__      = 'movie'
    id                 = Column(Integer, primary_key = True)
    tconst             = Column(String(255), unique = True)
    titleType          = Column(String(255))
    primaryTitle       = Column(String(255))
    originalTitle      = Column(String(255))
    startYear          = Column(String(255))
    endYear            = Column(String(255))
    runtimeMinutes     = Column(Integer)
    genres             = Column(Text)
    averageRating      = Column(Float)
    numVotes           = Column(Integer)
    principals         = relationship('Principal', secondary = principal_movie, back_populates = 'movies')

    def __init__(self, tconst, titleType, primaryTitle, originalTitle, startYear, endYear, runtimeMinutes, genres, averageRating, numVotes):
        self.tconst         = tconst
        self.titleType      = titleType
        self.primaryTitle   = primaryTitle
        self.originalTitle  = originalTitle
        self.startYear      = startYear
        self.endYear        = endYear
        self.runtimeMinutes = runtimeMinutes
        self.averageRating  = averageRating
        self.numVotes       = numVotes
        self.genres         = genres

    def __repr__(self):
        return "{}".format(self.primaryTitle)

    def get_actors(self):
        actors = []
        for prin in self.principals:
            for actor in prin.actors:
                characters = ",".join(eval(prin.characters)).replace('"', '')
                actors.append(actor.primaryName+' ('+characters+')')
        return actors


        
class Actor(Base):
    __tablename__     = 'actor'
    id                = Column(Integer, primary_key = True)
    nconst            = Column(String(255), unique = True)
    primaryName       = Column(String(255))
    birthYear         = Column(Integer)
    deathYear         = Column(Integer)
    primaryProfession = Column(String(255))
    principals         = relationship('Principal', secondary = principal_actor, back_populates = 'actors')

    def __init__(self, nconst, primaryName, birthYear, deathYear, primaryProfession):
        self.nconst            = nconst
        self.primaryName       = primaryName
        self.birthYear         = birthYear
        self.deathYear         = deathYear
        self.primaryProfession = primaryProfession

    def __repr__(self):
    	return "{}".format(self.primaryName)

    def get_movies(self):
        movies = []
        for prin in self.principals:
            for movie in prin.movies:
                movies.append(movie.primaryTitle)
        return movies


class Principal(Base):
    __tablename__  = 'principal'
    id             = Column(Integer, primary_key = True)
    tconst         = Column(String(255))
    nconst         = Column(String(255))
    category       = Column(String(255))
    job            = Column(String(255))
    characters     = Column(String(255))
    actors         = relationship("Actor", secondary = principal_actor, back_populates = "principals", lazy = "dynamic")
    movies         = relationship("Movie", secondary = principal_movie, back_populates = "principals", lazy = "dynamic")

    def __init__(self, tconst, nconst, category, job, characters):
        self.tconst     = tconst
        self.nconst     = nconst
        self.category   = category
        self.job        = job
        self.characters = characters
