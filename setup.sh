#!/bin/bash

# This script sets up an openaps environment to work with loop.sh,
# by defining the required devices, reports, and aliases.
#
# Released under MIT license. See the accompanying LICENSE.txt file for
# full terms and conditions
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

die() {
  echo "$@"
  exit 1
}

if [[ $# -ne 1 ]]; then
    echo "Usage: setup.sh <pump serial #>"
    exit
fi
serial=$1

# add devices
( ( cd ~/openaps-dev && git status ) || ( cd && openaps init openaps-dev ) ) || die "Can't init openaps-dev"
cd ~/openaps-dev || die "Can't cd openaps-dev"
openaps device show cgm 2>/dev/null || openaps device add cgm dexcom || die "Can't add CGM"
git add cgm.ini
grep -q pump.ini .gitignore 2>/dev/null || echo pump.ini >> .gitignore
git add .gitignore
openaps device show pump 2>/dev/null || openaps device add pump medtronic $serial || die "Can't add pump"
openaps device show oref0 2>/dev/null || openaps device add oref0 process oref0 || die "Can't add oref0"
git add oref0.ini

# add reports for frequently-refreshed monitoring data
mkdir monitor || die "Can't mkdir monitor"
openaps report show monitor/glucose.json.new 2>/dev/null || openaps report add monitor/glucose.json.new JSON cgm iter_glucose 5 || die "Can't add glucose.json.new"
openaps report show monitor/clock.json.new 2>/dev/null || openaps report add monitor/clock.json.new JSON pump read_clock || die "Can't add clock.json.new"
openaps report show monitor/temp_basal.json.new 2>/dev/null || openaps report add monitor/temp_basal.json.new JSON pump read_temp_basal || die "Can't add temp_basal.json.new"
openaps report show monitor/reservoir.json.new 2>/dev/null || openaps report add monitor/reservoir.json.new JSON pump reservoir || die "Can't add reservoir.json.new"
openaps report show monitor/pumphistory.json.new 2>/dev/null || openaps report add monitor/pumphistory.json.new JSON pump iter_pump_hours 4 || die "Can't add pumphistory.json.new"

# add reports for infrequently-refreshed settings data
mkdir settings || die "Can't mkdir settings"
openaps report show settings/bg_targets.json.new 2>/dev/null || openaps report add settings/bg_targets.json.new JSON pump read_bg_targets || die "Can't add bg_targets.json.new"
openaps report show settings/insulin_sensitivies.json.new 2>/dev/null || openaps report add settings/insulin_sensitivies.json.new JSON pump read_insulin_sensitivies || die "Can't add insulin_sensitivies.json.new"
openaps report show settings/basal_profile.json.new 2>/dev/null || openaps report add settings/basal_profile.json.new JSON pump read_selected_basal_profile || die "Can't add basal_profile.json.new"
openaps report show settings/settings.json.new 2>/dev/null || openaps report add settings/settings.json.new JSON pump read_settings || die "Can't add settings.json.new"

# add aliases
openaps alias show invoke 2>/dev/null || openaps alias add invoke "report invoke" || die "Can't add invoke"

