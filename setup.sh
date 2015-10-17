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

if [[ $# -lt 1 ]]; then
    openaps device show pump 2>/dev/null >/dev/null || die "Usage: setup.sh <pump serial #> [max_iob]"
fi
serial=$1

( ( cd ~/openaps-dev 2>/dev/null && git status ) || ( cd && openaps init openaps-dev ) ) || die "Can't init openaps-dev"
cd ~/openaps-dev || die "Can't cd openaps-dev"

if [[ $# -lt 2 ]]; then
    max_iob=0;
else
    max_iob=$2
fi
#grep -q max_iob max_iob.json 2>/dev/null ||
echo "{ "max_iob": $max_iob }" > max_iob.json
git add max_iob.json

# don't re-create devices if they already exist
openaps device show 2>/dev/null > /tmp/openaps-devices

# add devices
grep -q pump.ini .gitignore 2>/dev/null || echo pump.ini >> .gitignore
git add .gitignore
grep pump /tmp/openaps-devices || openaps device add pump medtronic $serial || die "Can't add pump"
grep cgm /tmp/openaps-devices || openaps device add cgm dexcom || die "Can't add CGM"
git add cgm.ini
grep oref0 /tmp/openaps-devices || openaps device add oref0 process oref0 || die "Can't add oref0"
git add oref0.ini
grep iob /tmp/openaps-devices || openaps device add iob process --require "pumphistory basal_profile clock" oref0 calculate-iob || die "Can't add iob"
git add iob.ini
grep get-profile /tmp/openaps-devices || openaps device add get-profile process --require "settings bg_targets isf basal_profile max_iob" oref0 calculate-iob || die "Can't add iob"
git add get-profile.ini

# don't re-create reports if they already exist
openaps report show 2>/dev/null > /tmp/openaps-reports

# add reports for frequently-refreshed monitoring data
ls monitor 2>/dev/null >/dev/null || mkdir monitor || die "Can't mkdir monitor"
grep monitor/glucose.json.new /tmp/openaps-reports || openaps report add monitor/glucose.json.new JSON cgm iter_glucose 5 || die "Can't add glucose.json.new"
grep monitor/clock.json.new /tmp/openaps-reports || openaps report add monitor/clock.json.new JSON pump read_clock || die "Can't add clock.json.new"
grep monitor/temp_basal.json.new /tmp/openaps-reports || openaps report add monitor/temp_basal.json.new JSON pump read_temp_basal || die "Can't add temp_basal.json.new"
grep monitor/reservoir.json.new /tmp/openaps-reports || openaps report add monitor/reservoir.json.new JSON pump reservoir || die "Can't add reservoir.json.new"
grep monitor/pumphistory.json.new /tmp/openaps-reports || openaps report add monitor/pumphistory.json.new JSON pump iter_pump_hours 4 || die "Can't add pumphistory.json.new"

# add reports for infrequently-refreshed settings data
ls settings 2>/dev/null >/dev/null || mkdir settings || die "Can't mkdir settings"
grep settings/bg_targets.json.new /tmp/openaps-reports || openaps report add settings/bg_targets.json.new JSON pump read_bg_targets || die "Can't add bg_targets.json.new"
grep settings/insulin_sensitivies.json.new /tmp/openaps-reports || openaps report add settings/insulin_sensitivies.json.new JSON pump read_insulin_sensitivies || die "Can't add insulin_sensitivies.json.new"
grep settings/basal_profile.json.new /tmp/openaps-reports || openaps report add settings/basal_profile.json.new JSON pump read_selected_basal_profile || die "Can't add basal_profile.json.new"
grep settings/settings.json.new /tmp/openaps-reports || openaps report add settings/settings.json.new JSON pump read_settings || die "Can't add settings.json.new"

# add aliases
openaps alias show invoke 2>/dev/null || openaps alias add invoke "report invoke" || die "Can't add invoke"

