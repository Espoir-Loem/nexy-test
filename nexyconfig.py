from nexy.core.models import NexyConfigModel
from nexy.frontend import react, vue

class NexyConfig(NexyConfigModel):
    useFF = [react(),vue()]
    # usePort = 4000
    useAliases = {"@": "src"}
    useTitle = "Nexy Web (FBR + React)"
    useVite = True
