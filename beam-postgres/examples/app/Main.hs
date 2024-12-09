{-# LANGUAGE OverloadedStrings #-}
module Main where

import Database.Beam.Migrate (stepNames, migrateScript)
import Database.Beam.Migrate.Simple (backendMigrationStepsScript)
import Data.Text (unpack)
import Pagila.Schema (migration)

main :: IO ()
main = do
  putStrLn "Migration steps:"
  mapM_ (putStrLn . unpack) (stepNames migration)
  putStrLn "---------"
  putStrLn "Migration script:"
  -- migrateScript () (\x -> ) migration
  putStrLn $ backendMigrationStepsScript _ migration
