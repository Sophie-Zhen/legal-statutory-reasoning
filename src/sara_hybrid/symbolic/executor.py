import os, shutil, importlib

# ------------------------------------------------------------------
# ---- Make PySwip accept Homebrew's layout on macOS ---------------
# ------------------------------------------------------------------
def _patch_pyswip():
    """Monkey-patch pyswip so it never insists on /Frameworks."""
    try:
        core = importlib.import_module("pyswip.core")
    except ModuleNotFoundError:
        return  # pyswip not imported yet
    # Replace the darwin finder with a version that only looks at SWI_HOME_DIR
    def _find_swipl_darwin_patched():
        home = os.getenv("SWI_HOME_DIR")
        if not home:
            return None, None
        arch = os.getenv("SWIPL_ARCH", f"{os.uname().machine}-darwin")
        lib_dir = os.path.join(home, "lib", "swipl", arch)
        lib = os.path.join(lib_dir, "libswipl.dylib")
        return lib if os.path.exists(lib) else None, home
    core._find_swipl_darwin = _find_swipl_darwin_patched

# Set env vars once
os.environ.setdefault("SWI_HOME_DIR", shutil.which("swipl") and
                      os.path.dirname(os.path.dirname(shutil.which("swipl"))))
os.environ.setdefault("SWIPL_ARCH", f"{os.uname().machine}-darwin")

_patch_pyswip()
# ------------------------------------------------------------------

from pyswip import Prolog
