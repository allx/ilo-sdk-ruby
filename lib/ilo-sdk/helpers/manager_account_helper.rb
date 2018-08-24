# (C) Copyright 2016 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

module ILO_SDK
  # Contains helper methods for Manager Account actions
  module ManagerAccountHelper
    # Get the Privilege(s)
    # @param [String, Symbol] username - return all if no username provided
    # @raise [RuntimeError] if the request failed
    # @return [Hash] privileges
    def get_account_privileges(username = nil)
      response = rest_get('/redfish/v1/AccountService/Accounts/')
      accounts = response_handler(response)['Items']
      privileges = Array.new
      accounts.each do |account|
        if username
          if account['Oem']['Hp']['LoginName'] == username
            return account['Oem']['Hp']['Privileges']
          end
        else
          privileges.push({
            "LoginName" => account['Oem']['Hp']['LoginName'],
            "Privileges" => account['Oem']['Hp']['Privileges']
          })
        end
      end
      if username
        return nil
      else
        return privileges
      end
    end

    # Set the privileges for a user
    # @param [TrueClass, FalseClass] username
    # @param [Hash] privileges
    # @option privileges [TrueClass, FalseClass] :LoginPriv
    # @option privileges [TrueClass, FalseClass] :RemoteConsolePriv
    # @option privileges [TrueClass, FalseClass] :UserConfigPriv
    # @option privileges [TrueClass, FalseClass] :VirtualMediaPriv
    # @option privileges [TrueClass, FalseClass] :VirtualPowerAndResetPriv
    # @option privileges [TrueClass, FalseClass] :iLOConfigPriv
    # @raise [RuntimeError] if the request failed
    # @return true
    def set_account_privileges(username, privileges)
      response = rest_get('/redfish/v1/AccountService/Accounts/')
      accounts = response_handler(response)['Items']
      id = '0'
      accounts.each do |account|
        if account['Oem']['Hp']['LoginName'] == username
          id = account['Id']
          break
        end
      end
      new_action = {
        'Oem' => {
          'Hp' => {
            'Privileges' => privileges
          }
        }
      }
      response = rest_patch("/redfish/v1/AccountService/Accounts/#{id}/", body: new_action)
      response_handler(response)
      true
    end
  end
end
