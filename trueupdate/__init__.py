import subprocess
import sys

class Chart(object):
    def __setattr__(self, name, value):
        if name == 'status':
            value = value.casefold()
        if 'update_available' in name:
            value = True if value.casefold() == "true" else False
        super(Chart, self).__setattr__(name, value)

    def new_attr(self, attr):
        setattr(self, attr, attr)

INSTALLED_CHARTS = []
CATALOG = "ALL"
SEMVER = "minor"

def parse_headers(charts: str):
    for line in charts.split("\n"):
        if line.startswith("+-"):
            continue
        if "name" in line.casefold():
            return [col.strip() for col in line.casefold().strip().split("|") if col and col != ""]

def parse_charts(charts: str):
    headers = parse_headers(charts)
    table_data = charts.split("\n")[3:-2:]  # Skip the header part of the table
    for row in table_data:
        row = [section.strip() for section in row.split("|") if section and section != ""]
        chart = Chart()
        for item in zip(headers, row):
            setattr(chart, item[0], item[1])
        INSTALLED_CHARTS.append(chart)

def check_semver(current: str, latest: str):
    split_current_semver = current.split(".", 3)
    split_latest_semver = latest.split(".", 3)
    if split_current_semver[0] != split_latest_semver[0]:
      type="major"
      if SEMVER == "major":
        return True
    if split_current_semver[1] != split_latest_semver[1]:
      type="minor"
      if SEMVER != "patch":
        return True
    if split_current_semver[2] != split_latest_semver[2]:
      type="patch"
      return True
    return False
    

def execute_upgrades():
    if CATALOG == "ALL":
      filtered = filter(lambda a: a.update_available and a.status == "active", INSTALLED_CHARTS)
    else:
      filtered = filter(lambda a: a.update_available and a.status == "active" and a.catalog == CATALOG, INSTALLED_CHARTS)
    for chart in filtered:
      pre_update_ver = chart.human_version
      post_update_ver = chart.human_latest_version
      split_current_version = chart.human_version.split("_", 1)
      current_version = split_current_version[1]
      split_latest = chart.human_latest_version.split("_", 1)
      latest_version = split_latest[1]
      if check_semver(current_version, latest_version):
        pre_update_ver = chart.human_version
        result = subprocess.run(['cli', '-c', f'app chart_release upgrade release_name={chart.name}'], capture_output=True)
        post_update_ver = chart.human_latest_version
        if "Upgrade complete" not in result.stdout.decode('utf-8'):
            print(f"{chart.name} failed to upgrade. \n{result.stdout.decode('utf-8')}")
        else:
            print(f"{chart.name} upgraded ({pre_update_ver} --> {post_update_ver})")

def fetch_charts():
  rawcharts = subprocess.run(["cli", "-c", "app chart_release query"], stdout=subprocess.PIPE)
  charts = rawcharts.stdout.decode('utf-8')
  return(charts)
  
def run()
    get_args()
    charts = fetch_charts()
    parse_charts(charts)
    execute_upgrades()
  
def get_args():
  if len(sys.argv) == 3:
    SEMVER = sys.argv[2] or "minor"
  if len(sys.argv) == 2:
    CATALOG = sys.argv[1] or "ALL"

if __name__ == '__main__':
    run()
    exit(0)

