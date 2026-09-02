import os
import sys
import subprocess

def build_executable():
    """
    Builds the executable using PyInstaller.
    Ensures that QML and asset files are included in the bundle.
    """
    # Get the project root directory (parent of installer/)
    installer_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(installer_dir, ".."))
    
    os.chdir(project_root)
    
    # Path separator for PyInstaller --add-data
    sep = ';' if sys.platform == 'win32' else ':'
    
    # Check if pyinstaller is available
    try:
        import PyInstaller.__main__
    except ImportError:
        print("PyInstaller is not installed. Installing it now...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
        import PyInstaller.__main__

    print("Building ProjectTracker executable...")
    
    main_script = os.path.join(project_root, 'main.py')
    qml_dir = os.path.join(project_root, 'qml')
    assets_dir = os.path.join(project_root, 'assets')
    
    PyInstaller.__main__.run([
        main_script,
        '--name=ProjectTracker',
        '--windowed',         # Do not open a console window
        '--onefile',          # Bundle into a single executable
        f'--add-data={qml_dir}{sep}qml',
        f'--add-data={assets_dir}{sep}assets',
        '--clean',
        '--noconfirm',
        '--distpath=installer/dist',
        '--workpath=installer/build',
        '--specpath=installer/'
    ])
    
    print("\nBuild complete!")
    print(f"Your executable is located in: {os.path.join(installer_dir, 'dist')}")

if __name__ == "__main__":
    build_executable()
