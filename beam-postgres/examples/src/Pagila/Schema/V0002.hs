{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}

module Pagila.Schema.V0002
  ( module V0001'
  , FilmActorT(..), FilmActor
  , PrimaryKey(..), FilmActorId
  , migration, PagilaDb
  ) where

import qualified Pagila.Schema.V0001 as V0001
import qualified Pagila.Schema.V0001 as V0001' hiding (PagilaDb, migration)

import Database.Beam
    ( Generic,
      Columnar,
      Identity,
      Beamable,
      Table(..),
      TableEntity,
      Database,
      smallint )
import Database.Beam.Postgres ( Postgres )
import Database.Beam.Migrate.Types
    ( CheckedDatabaseSettings, Migration )
import Database.Beam.Migrate.SQL.Tables
    ( field, notNull, createTable, preserve )

import Data.Time.LocalTime (LocalTime)

-- film actor

data FilmActorT f
  = FilmActorT
  { filmActorFilm :: PrimaryKey V0001.FilmT f
  , filmActorActor :: PrimaryKey V0001.ActorT f
  , filmCategoryLastUpdate :: Columnar f LocalTime
  } deriving Generic
type FilmActor = FilmActorT Identity
deriving instance Eq FilmActor; deriving instance Show FilmActor

instance Table FilmActorT where
  data PrimaryKey FilmActorT f = FilmActorId (PrimaryKey V0001.ActorT f) (PrimaryKey V0001.FilmT f)
    deriving Generic
  primaryKey fa = FilmActorId (filmActorActor fa) (filmActorFilm fa)
type FilmActorId = PrimaryKey FilmActorT Identity
deriving instance Eq FilmActorId; deriving instance Show FilmActorId

-- Pagila db

instance Beamable FilmActorT
instance Beamable (PrimaryKey FilmActorT)

data PagilaDb f
  = PagilaDb
  { actor      :: f (TableEntity V0001.ActorT)
  , address    :: f (TableEntity V0001.AddressT)
  , city       :: f (TableEntity V0001.CityT)
  , country    :: f (TableEntity V0001.CountryT)
  , category   :: f (TableEntity V0001.CategoryT)
  , customer   :: f (TableEntity V0001.CustomerT)
  , film       :: f (TableEntity V0001.FilmT)
  , filmCategory :: f (TableEntity V0001.FilmCategoryT)
  , filmActor  :: f (TableEntity FilmActorT)
  , language   :: f (TableEntity V0001.LanguageT)
  , store      :: f (TableEntity V0001.StoreT)
  , staff      :: f (TableEntity V0001.StaffT)
  } deriving Generic
instance Database Postgres PagilaDb

migration :: CheckedDatabaseSettings Postgres V0001.PagilaDb
          -> Migration Postgres (CheckedDatabaseSettings Postgres PagilaDb)
migration oldDb =
  PagilaDb
    <$> preserve (V0001.actor oldDb)
    <*> preserve (V0001.address oldDb)
    <*> preserve (V0001.city oldDb)
    <*> preserve (V0001.country oldDb)
    <*> preserve (V0001.category oldDb)
    <*> preserve (V0001.customer oldDb)
    <*> preserve (V0001.film oldDb)
    <*> preserve (V0001.filmCategory oldDb)
    <*> createTable "film_actor"
          (FilmActorT (V0001.FilmId (field "film_id" smallint notNull))
                                    (V0001.ActorId (field "actor_id" smallint notNull))
                                    V0001.lastUpdateField)
    <*> preserve (V0001.language oldDb)
    <*> preserve (V0001.store oldDb)
    <*> preserve (V0001.staff oldDb)
