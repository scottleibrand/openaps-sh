#!/bin/bash

# Fetch pump settings, and update .json files from the .new.json files if all
# was successful
#
# Copyright (c) 2015 OpenAPS Contributors
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

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

die() { echo "$@" ; exit 1; }

echo "Querying pump settings"
( openaps pumpsettings || openaps pumpsettings ) 2>/dev/null
grep -q '"start": "00:00:00",' carb_ratio.json.new || die "Couldn't find first carb ratio schedule entry: bailing"
grep -q '"start": "00:00:00",' current_basal_profile.json.new || die "Couldn't find first basal profile schedule entry: bailing"
grep -q '"start": "00:00:00",' isf.json.new || die "Couldn't find first ISF schedule entry: bailing"
grep -q '"start": "00:00:00",' bg_targets.json.new || die "Couldn't find first BG targets schedule entry: bailing"
grep -q '"sensitivity": 0,' isf.json.new && die "Sensitivity of 0 makes no sense: bailing"
grep -q '"units": null,' carb_ratio.json.new && die "null units for carb ratio: bailing"
grep -q '"rate": 0.0' current_basal_profile.json.new && die "basal rates < 0.1U/hr not supported: bailing"
grep -q '"insulin_action_curve": 0' pump_settings.json.new && die "DIA of 0 makes no sense: bailing"
grep -q insulin_action_curve pump_settings.json.new && cp pump_settings.json.new pump_settings.json
grep -q "mg/dL" bg_targets.json.new && cp bg_targets.json.new bg_targets.json
grep -q sensitivity isf.json.new && cp isf.json.new isf.json
grep -q rate current_basal_profile.json.new && cp current_basal_profile.json.new current_basal_profile.json
grep -q grams carb_ratio.json.new && cp carb_ratio.json.new carb_ratio.json
