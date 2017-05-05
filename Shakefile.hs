-- (script)
-- Shakefile
{-# OPTIONS_GHC -fno-warn-wrong-do-bind #-}

import Control.Applicative ((<$>))
import Development.Shake

opts :: ShakeOptions
opts = shakeOptions { shakeFiles    = ".shake/" }

main :: IO ()
main = shakeArgs opts $ do
    want ["out/report.doc","out/report.pdf","out/report.html"]

    "build-some" ~> do
        need ["out/report.pdf","out/report.doc"]
        cmd "fortune" [""]

    "out/report.doc" %> \f -> do
        need <$> srcFiles
        cmd "pandoc" [ "src/report.md", "-o", f ]

    "out/report.pdf" %> \f -> do
        need <$> srcFiles
        cmd "pandoc" [ "src/report.md", "-o", f, "-V", "links-as-notes" ]

    "out/report.html" %> \f -> do
        deps <- srcFiles
        need $ "css/report.css" : deps
        cmd "pandoc" [ "src/report.md", "-o", f, "-c", "css/report.css", "-S" ]

    "img/img2.jpg" %> \f -> do
        cmd "wget" [ "http://example.com/img2.jpg", "-O", f ]

    "clean" ~> removeFilesAfter ".shake" ["//*"]

srcFiles :: Action [FilePath]
srcFiles = getDirectoryFiles ""
    [ "src/report.md" , "img/*.jpg" ]