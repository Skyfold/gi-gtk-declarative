{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Example of using the 'Dialog' widget. Note that it's not using
-- the action bar support, nor the response codes mechanism of GTK+
-- dialogs. Those are more object-oriented APIs that do not fit well
-- with gi-gtk-declarative.
module Dialog where

import           Control.Monad                  ( void )
import           Data.Maybe

import           Data.Text                      ( Text )
import           GI.Gtk                         ( Align(..)
                                                , Box(..)
                                                , Button(..)
                                                , Dialog(..)
                                                , Label(..)
                                                , Orientation(..)
                                                )
import           GI.Gtk.Declarative
import           GI.Gtk.Declarative.App.Simple

newtype State = State (Maybe Text)

data Event = Confirmed | Cancelled | Closed

view' :: State -> AppView Dialog Event
view' (State msg) =
  bin
      Dialog
      [ #title := "Hello"
      , on #deleteEvent (const (True, Closed))
      , #widthRequest := 300
      , #heightRequest := 200
      ]
    $ container
        Box
        [#orientation := OrientationVertical]
        [ BoxChild defaultBoxChildProperties { expand = True, fill = True }
                   msgLabel
        , paddedAround 5 $ container
          Box
          [#halign := AlignEnd, #spacing := 5]
          [ widget Button [#label := "Cancel", on #clicked Cancelled]
          , widget Button [#label := "OK", on #clicked Confirmed]
          ]
        ]
 where
  msgLabel = widget Label [#label := fromMaybe "Nothing here yet." msg]
  -- | Wrap a widget in two boxes (vertical and horizontal) to pad
  -- it evenly.
  paddedAround spacing =
    container Box [#orientation := OrientationVertical]
      . pure
      . BoxChild defaultBoxChildProperties { padding = spacing
                                           , expand  = True
                                           , fill    = True
                                           }
      . container Box []
      . pure
      . BoxChild defaultBoxChildProperties { padding = spacing
                                           , expand  = True
                                           , fill    = True
                                           }

update' :: State -> Event -> Transition State Event
update' _ Confirmed = Transition (State (Just "Confirmed.")) (pure Nothing)
update' _ Cancelled = Transition (State (Just "Cancelled.")) (pure Nothing)
update' _ Closed    = Exit

main :: IO ()
main = void $ run App { view         = view'
                      , update       = update'
                      , inputs       = []
                      , initialState = State Nothing
                      }

