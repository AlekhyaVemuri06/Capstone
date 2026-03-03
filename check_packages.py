"""
check_packages.py
Called by setup_venv.bat and setup_venv.ps1 to verify installed packages.
"""
import importlib
import sys

CORE_PACKAGES = [
    ("numpy",      "numpy"),
    ("pandas",     "pandas"),
    ("sklearn",    "scikit-learn"),
    ("matplotlib", "matplotlib"),
    ("seaborn",    "seaborn"),
]

DL_PACKAGES = [
    ("tensorflow",      "tensorflow==2.19.0"),
    ("tf_keras",        "tf-keras"),
    ("tensorflow_hub",  "tensorflow-hub"),
    ("transformers",    "transformers==4.47.0"),
    ("torch",           "torch==2.6.0"),
]

print()
print("Core packages (via system site-packages):")
for mod_name, pkg_name in CORE_PACKAGES:
    try:
        mod = importlib.import_module(mod_name)
        version = getattr(mod, "__version__", "installed")
        print(f"  OK  {pkg_name:<22} {version}")
    except ImportError:
        print(f"  --  {pkg_name:<22} NOT FOUND  ->  pip install {pkg_name}")

print()
print("Deep learning packages (optional - needed for Models 2-4):")
for mod_name, install_cmd in DL_PACKAGES:
    try:
        mod = importlib.import_module(mod_name)
        version = getattr(mod, "__version__", "installed")
        print(f"  OK  {mod_name:<22} {version}")
    except ImportError:
        print(f"  --  {mod_name:<22} not found  ->  pip install {install_cmd}")

print()
