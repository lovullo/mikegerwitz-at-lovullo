--
-- Personal xmonad configuration for Mike Gerwitz
--

import XMonad
import XMonad.Util.Paste
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- mouse warp
import Data.Ratio
import XMonad.Actions.Warp


-- key bindings
keybindings conf@(XConfig {XMonad.modMask = modm}) = M.fromList $ [
  -- launch terminal
  ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),

  -- dmenu used as launcher
  ((modm, xK_p), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\""),

  -- window manipulation
  ((modm .|. shiftMask, xK_c),      kill),
  ((modm, xK_n),      refresh),
  ((modm, xK_j),      windows W.focusDown),
  ((modm, xK_k),      windows W.focusUp),
  ((modm, xK_m),      windows W.focusMaster),
  ((modm, xK_Return), windows W.swapMaster),
  ((modm .|. shiftMask, xK_j),      windows W.swapDown),
  ((modm .|. shiftMask, xK_k),      windows W.swapUp),

  -- layout manipulation
  ((modm, xK_space),  sendMessage NextLayout),
  ((modm, xK_h),      sendMessage Shrink),
  ((modm, xK_l),      sendMessage Expand),
  ((modm, xK_t),      withFocused $ windows . W.sink),
  ((modm, xK_comma),  sendMessage $ IncMasterN 1),
  ((modm, xK_period), sendMessage $ IncMasterN (-1)),

  -- mouse cursor manipulation
  ((modm, xK_z), warpToWindow (1%2) (1%2)),

  -- paste X selection
  ((modm, xK_v), pasteSelection),

  -- screenshot (select window/area; root)
  ((modm, xK_s), spawn "~/bin/screenshot"),
  ((modm, xK_a), spawn "saveas=1 ~/bin/screenshot"),
  ((modm .|. shiftMask, xK_s), spawn "~/bin/screenshot -window root"),
  ((modm .|. shiftMask, xK_a), spawn "saveas=1 ~/bin/screenshot -window root"),

  -- x_X
  ((modm, xK_q), restart "xmonad" True),
  ((modm .|. shiftMask, xK_q), io $ exitWith ExitSuccess) ]

  ++

  --
  -- LoVullo; moveme
  --
  -- away from desk
  [ ((modm, xK_Print ), spawn "afd 1"),
    ((modm, xK_Pause ), spawn "afd"),

    ((modm, xK_Insert ), spawn "phonectl --ext 324 --chm 1"),
    ((modm, xK_Home ), spawn "wkgrp-toggle"),
    ((modm, xK_Prior ), spawn "phonectl --ext 324 --chm 5"),

    -- gromit
    ((modm, xK_grave ), spawn "gromit-toggle"),
    ((modm .|. shiftMask, xK_grave ), spawn "gromit --visibility"),
    ((modm .|. shiftMask, xK_Escape ), spawn "gromit --clear"),

    -- system lockdown
    ((modm, xK_Escape ), spawn "secure-sys"),

    -- clear mail indicator
    ((modm, xK_Caps_Lock ), spawn ">/tmp/.keyind") ]

  ++

  --
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  --
  [((m .|. modm, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9 ]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

  ++

  --
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  --
  [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_f, xK_r, xK_e, xK_w] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


main = xmonad defaultConfig {
  terminal = "urxvt",
  modMask  = mod4Mask,
  keys     = keybindings,

  -- mouse
  focusFollowsMouse = True,

  -- border
  borderWidth        = 1,
  normalBorderColor  = "#000000",
  focusedBorderColor = "#204a87",

  -- window rules
  manageHook = composeAll [
    className =? "Gimp" --> doFloat
  ]
}
