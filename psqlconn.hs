#!/usr/bin/env stack
-- stack --resolver lts-12.21 script
import Data.String
import Data.List
import System.Directory
import System.Environment
import System.Exit
import System.Process

pairs :: [a] -> [(a, a)]
pairs (x1:x2:[]) = [(x1, x2)]
pairs (x1:x2:rest) = [(x1, x2)] ++ pairs rest

stripEmptyRows :: [String] -> [String]
stripEmptyRows = filter (/= "")

strip :: String -> String
strip = reverse . dropWhile (== ' ') . reverse . dropWhile (== ' ')

getNames :: String -> String
getNames = strip . dropWhile (== '#')

pairConnections :: String -> [([String], String)]
pairConnections =
  map (\(x, y) -> (map strip $ splitOn ',' $ getNames x, y)) .
  pairs . stripEmptyRows . lines

splitOn :: Char -> String -> [String]
splitOn c str = splitOn' c str "" []

splitOn' :: Char -> String -> String -> [String] -> [String]
splitOn' _ (x:[]) accStr acc = acc ++ [accStr ++ [x]]
splitOn' c (x:xs) accStr acc =
  case c == x of
    True -> splitOn' c xs "" (acc ++ [accStr])
    False -> splitOn' c xs (accStr ++ [x]) acc

getByName :: String -> [([String], String)] -> String
getByName n pairs = snd $ head $ filter (\(x, _) -> elem n x) pairs

create_psql_command :: [String] -> String
create_psql_command (host:_:user:_) = unwords ["psql", "-h", host, "-U ", user]

helpMessage :: String
helpMessage = unlines [
        "Usage instructions:",
        "",
        "Put comments above the rows in your ~/.pgpass file, like this:",
        "# my name, another name",
        "some-host::my_user:super_secret_password",
        "and then run",
        "psqlconn my name"
        ]

printUsageAndQuit :: IO ExitCode
printUsageAndQuit = do
    putStrLn helpMessage
    exitWith ExitSuccess

main :: IO ExitCode
main = do
  args <- getArgs
  homeDir <- getHomeDirectory
  contents <- readFile $ intercalate "" [homeDir, "/.pgpass"]
  case length args of
    0 -> printUsageAndQuit
    n ->
      system $
      create_psql_command $
      splitOn ':' $ getByName (strip $ unwords args) $ pairConnections contents
