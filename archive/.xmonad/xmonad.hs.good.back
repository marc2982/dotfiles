import XMonad hiding (handleEventHook, keys, layoutHook, logHook,
                      manageHook, modMask, startupHook, workspaces)
import qualified XMonad
import qualified XMonad.StackSet as W

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (avoidStruts, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.SetWMName (setWMName)
import qualified XMonad.Layout.Decoration as Decoration
import XMonad.Layout.FixedColumn (FixedColumn(..))
import XMonad.Layout.LayoutHints (layoutHints)
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect

import Control.Applicative ((<$>))
import Control.Monad (liftM)
import Control.Monad.State (when)
import Data.Bits ((.|.))
import Data.List (isPrefixOf, isSuffixOf)
import Data.Maybe (isJust)
import Data.Monoid (All)
import qualified Data.Map as M

main :: IO ()
main = xmonad myConfig

------------------------------------------------------------
-- Configurations
------------------------------------------------------------

myTerminal = "gnome-terminal"

myConfig = defaultConfig
            { XMonad.focusedBorderColor = fgColor
            , XMonad.handleEventHook    = handleEventHook
            , XMonad.keys               = addKeys keys
            , XMonad.layoutHook         = layoutHook
            , XMonad.logHook            = logHook
            , XMonad.manageHook         = manageHook
            , XMonad.modMask            = super
            , XMonad.mouseBindings      = mouse
            , XMonad.normalBorderColor  = dimColor
            , XMonad.startupHook        = startupHook
            , XMonad.workspaces         = workspaces
            , XMonad.terminal           = myTerminal
            }

theme :: Decoration.Theme
theme = Decoration.defaultTheme
        { Decoration.activeColor         = dimColor
        , Decoration.inactiveColor       = bgColor
        , Decoration.activeBorderColor   = dimColor
        , Decoration.inactiveBorderColor = dimColor
        , Decoration.activeTextColor     = fgColor
        , Decoration.inactiveTextColor   = fgColor
        , Decoration.fontName            = font
        }


------------------------------------------------------------
-- Configuration definitions
------------------------------------------------------------
super :: KeyMask
super = mod4Mask

bgColor, dimColor, fgColor, font :: [Char]
bgColor  = "#3f3f3f"
dimColor = "#5f5f5f"
fgColor  = "#dcdccc"
font     = "xft:Bitstream Vera Sans Mono-9"

keys :: M.Map (KeyMask, KeySym) (X ())
keys = M.fromList $
    [ ((mod4Mask .|. shiftMask, xK_h), sendMessage MirrorShrink)
    , ((mod4Mask .|. shiftMask, xK_l), sendMessage MirrorExpand)
    ]
    ++
    [((m .|. mod4Mask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_v, xK_z] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

mouse :: XConfig Layout -> M.Map (ButtonMask, Button) (Window -> X ())
mouse _ = M.fromList $
    [ ((super .|. shift, button1), (\w -> focus w >> float w))
    , ((super,           button1), mouseAction mouseMoveWindow)
    , ((super .|. ctrl,  button1), mouseAction mouseResizeWindow)
    ]
    where ctrl  = controlMask
          shift = shiftMask
          mouseAction f = \w -> whenFloat w (focus w >> f w
                                                     >> windows W.shiftMaster)

layoutHook =
    smartBorders $
    layoutHints $
    avoidStruts $
    ResizableTall 1 (1/100) (1/2) [] ||| simpleTabbed ||| (Mirror $ ResizableTall 1 (1/100) (1/2) [])

startupHook :: X ()
startupHook = ewmhDesktopsStartup
              >> setWMName "LG3D"

handleEventHook :: Event -> X All
handleEventHook = ewmhDesktopsEventHook

logHook :: X ()
logHook = ewmhDesktopsLogHook

manageHook :: ManageHook
manageHook = composeAll
             [ isFullscreen --> doFullFloat
             -- floats should always appear at the very top
             , floating                      --> doF W.shiftMaster
             -- Some windows should always come first...
             , className <? [ "Emacs"
                            , "GV"
                            , "XDvi"
                            , "Xpdf"
                            ]                --> doF W.shiftMaster
             -- apps that are bad at tiling
             , className <? [ "feh"
                            , "Gitk"
                            , "Kompare"
                            , "Meld"
                            , "Mbrowse"
                            , "Orage"
                            --, "Pidgin"
                            , "TransientShell"
                            , "Zenity"
                            --, "Sunbird-bin"
                            , "Guake.py"
                            , "/usr/lib/gnome-do/Do.exe"
                            , "Xfrun4"
                            , "Do"
                            ]                --> doFloat
             , (liftM $ isPrefixOf "Speedbar") title --> doFloat

             --
             , manageDocks
             ] <+> doF W.swapDown
    where
      floating = (ask >>= liftX . willFloat)
                 -- gnome panel applets make everything shift around
                 -- when shifted to master.
                 <&&> (liftM (not . isSuffixOf "-panel")) resource

workspaces :: [[Char]]
workspaces = ["αʹ", "βʹ", "γʹ", "δʹ", "εʹ", "ϝʹ", "ζʹ", "ηʹ", "θʹ", "ιʹ"]

------------------------------------------------------------
-- Utility Functions
------------------------------------------------------------

type KeyMap = M.Map (ButtonMask, KeySym) (X ())

-- | Add the given keymap @k@ to the default XMonad keymap, choosing
--   elements from @k@ in case of conflicting bindings.
addKeys :: KeyMap -> XConfig Layout -> KeyMap
addKeys k c = M.union k $ XMonad.keys defaultConfig c

-- | View the most recently viewed workspace
viewPrev :: W.StackSet i l a s sd -> W.StackSet i l a s sd
viewPrev s = s { W.current = (W.current s) { W.workspace = head (W.hidden s) }
               , W.hidden = W.workspace (W.current s) : tail (W.hidden s) }

-- | Perform the X action defined by @f@ when @w@ is a floating
--   window, and do nothing otherwise.
whenFloat :: Window -> X () -> X ()
whenFloat w f = isFloat w >>= \b -> when b f

-- | Determine whether or not @w@ is a floating window
isFloat :: Window -> X Bool
isFloat w = gets windowset >>= \ws -> return (M.member w $ W.floating ws)

-- This is logic copied from XMonad.Operations.manage, since
-- manageHook is called before windows are floated
-- | Determine if @w@ will be floated when it becomes managed.
willFloat :: Window -> X Bool
willFloat w = withDisplay $ \d -> do
                sh <- io $ getWMNormalHints d w
                let isFixedSize = sh_min_size sh /= Nothing
                                  && sh_min_size sh == sh_max_size sh
                isTransient <- isJust <$> io (getTransientForHint d w)
                f <- isFloat w
                return (isFixedSize || isTransient || f)

-- | Return 'True' if @q@ is an element of @xs@
q <? xs = fmap (flip elem xs) q
