import sys, os, logging
logging.basicConfig(level=logging.DEBUG)

wrapperdir = sys.argv[1]
toolsdir = sys.argv[2]
includedir = sys.argv[3]
srcdir = sys.argv[4]
xmldir = sys.argv[5]

sys.path.insert(0, wrapperdir)
sys.path.insert(0, toolsdir)
import genwrapper

try:
    g = genwrapper.GenWrapper(includedir, srcdir, xmldir)
    g.render_all()
    print("render_all completed")
    print("Files in srcdir:", os.listdir(srcdir))
    print("Files in includedir:", os.listdir(includedir))
except Exception as e:
    import traceback
    traceback.print_exc()
