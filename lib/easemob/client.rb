require_relative 'http_client'
require 'json'
require 'active_support/core_ext/hash/keys'

module Easemob
  class Client
    attr_reader :client_id, :client_secret, :host, :org_name, :app_name, :base_url
    attr_writer :token
    def initialize
      @client_id = Easemob.configuration.client_id
      @client_secret = Easemob.configuration.client_secret
      @host = Easemob.configuration.host || 'https://a1.easemob.com'
      @org_name = Easemob.configuration.org_name
      @app_name = Easemob.configuration.app_name
      @http_client = HttpClient.new
      @base_url = "#{@host}/#{@org_name}/#{@app_name}"
    end

    def token
      @token or raise "No token, please set it first"
    end

    # 登录并授权
    def authorize
      url = "#{@base_url}/token"
      params = {
        grant_type: 'client_credentials',
        client_id: @client_id,
        client_secret: @client_secret
      }
      uri, req = @http_client.post_request(url, params)
      http_submit(uri, req)
    end

    ## 用户体系集成

    # 注册IM用户[单个]
    def create_user(username, password, nickname = nil)
      url = "#{@base_url}/users"
      headers = token_header
      params = {
        username: username,
        password: password,
        nickname: nickname
      }
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 注册IM用户[批量]
    def create_users(users = [])
      url = "#{@base_url}/users"
      headers = token_header
      params = users
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 获取IM用户[单个]
    def get_user(username)
      url = "#{@base_url}/users/#{username}"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 获取IM用户[批量]
    def get_users(limit = 10)
      url = "#{@base_url}/users"
      headers = token_header
      params = { limit: limit }
      uri, req = @http_client.get_request(url, params, headers)
      http_submit(uri, req)
    end

    # 删除IM用户[单个]
    def destroy_user(username)
      url = "#{@base_url}/users/#{username}"
      headers = token_header
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 删除IM用户[批量]
    def destroy_users(limit = 2)
      url = "#{@base_url}/users"
      headers = token_header
      params = { limit: limit }
      uri, req = @http_client.del_request(url, params, headers)
      http_submit(uri, req)
    end

    # 重置IM用户密码
    def reset_password(username, newpassword)
      url = "#{@base_url}/users/#{username}/password"
      headers = token_header
      params = { newpassword: newpassword }
      uri, req = @http_client.put_request(url, params, headers)
      http_submit(uri, req)
    end

    # 修改用户昵称
    def reset_nickname(username, nickname)
      url = "#{@base_url}/users/#{username}"
      headers = token_header
      params = { nickname: nickname }
      uri, req = @http_client.put_request(url, params, headers)
      http_submit(uri, req)
    end

    # 给IM用户的添加好友
    # FIXME
    def add_friend(owner_username, friend_username)
      url = "#{@base_url}/users/#{owner_username}/contacts/users/#{friend_username}"
      headers = token_header
      uri, req = @http_client.post_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 解除IM用户的好友关系
    # FIXME
    def remove_friend(owner_username, friend_username)
      url = "#{@base_url}/users/#{owner_username}/contacts/users/#{friend_username}"
      headers = token_header
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查看好友
    def friends(owner_username)
      url = "#{@base_url}/users/#{owner_username}/contacts/users"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 往IM用户的黑名单中加人
    def block(owner_username, usernames = [])
      url = "#{@base_url}/users/#{owner_username}/blocks/users"
      headers = token_header
      params = { usernames: usernames }
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 获取IM用户的黑名单
    def black_list(owner_username)
      url = "#{@base_url}/users/#{owner_username}/blocks/users"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 从IM用户的黑名单中减人
    def unblock(owner_username, blocked_username)
      url = "#{@base_url}/users/#{owner_username}/blocks/users/#{blocked_username}"
      headers = token_header
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查看用户在线状态
    def online_status(username)
      url = "#{@base_url}/users/#{username}/status"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查询离线消息数
    def offline_msg_count(owner_username)
      url = "#{@base_url}/users/#{owner_username}/offline_msg_count"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查询某条离线消息状态
    def offline_msg_status(username, msg_id)
      url = "#{@base_url}/users/#{username}/offline_msg_status/#{msg_id}"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 用户账号禁用
    def deactivate_user(username)
      url = "#{@base_url}/users/#{username}/deactivate"
      headers = token_header
      uri, req = @http_client.post_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 用户账号解禁
    def activate_user(username)
      url = "#{@base_url}/users/#{username}/activate"
      headers = token_header
      uri, req = @http_client.post_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 强制用户下线
    def disconnect_user(username)
      url = "#{@base_url}/users/#{username}/disconnect"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # ==========================================================================
    ## 聊天记录

    # 导出聊天记录
    def export_chat_msgs(ql = nil, limit = nil, cursor = nil)
      url = "#{@base_url}/chatmessages"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # ==========================================================================
    # skip
    ## 图片语音文件上传、下载
    # note: 只有app的登陆用户才能够上传文件
    # 上传语音图片
    # 下载图片,语音文件
    # 下载缩略图

    # ==========================================================================
    # skip
    ## 聊天相关API

    # 发送文本消息
    # 发送图片消息
    # ...
    def send_cmd(username, action, ext_attrs={}) 
      url = "#{@base_url}/messages"
      headers = token_header
      params = {
        target_type: "users",
        target: [username].flatten,
        msg: {
          type: "cmd",
          action: action,
        }
      }
      params.merge!(ext: ext_attrs) if ext_attrs.length > 0
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    def send_text(username, text, ext_attrs={}) 
      url = "#{@base_url}/messages"
      headers = token_header
      params = {
        target_type: "users",
        target: [username].flatten,
        msg: {
          type: "txt",
          msg: text,
        }
      }
      params.merge!(ext: ext_attrs) if ext_attrs.length > 0
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # ==========================================================================
    ## 群组管理

    # 获取app中所有的群组
    def groups
      url = "#{@base_url}/chatgroups"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 获取一个或者多个群组的详情
    def groups_details(group_ids = [])
      params = group_ids.join(',')
      url = "#{@base_url}/chatgroups/#{params}"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 创建一个群组
    def create_group(group_params = {})
      url = "#{@base_url}/chatgroups"
      headers = token_header
      group_private_or_not = group_params[:group_private_or_not] || false  # 是否是公开群, 此属性为必须的,为false时为私有群
      maxusers = group_params[:maxusers] || 200  # 群组成员最大数(包括群主), 值为数值类型,默认值200,此属性为可选的
      approval = group_params[:approval] || false  # 加入公开群是否需要批准, 默认值是false（加群不需要群主批准）, 此属性为可选的,只作用于公开群
      params = {
        groupname: group_params[:groupname],  # 群组名称, 此属性为必须的
        desc: group_params[:desc],  # 群组描述, 此属性为必须的
        public: group_private_or_not,
        maxusers: maxusers,
        approval: approval,
        owner: group_params[:owner]  # 群组的管理员, 此属性为必须的
      }
      # 群组成员,此属性为可选的,但是如果加了此项,数组元素至少一个（注：群主jma1不需要写入到members里面）
      params.merge!({ members: group_params[:members] }) if group_params[:members]
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 修改群组信息
    def update_group_info(group_id, group_params = {})
      url = "#{@base_url}/chatgroups/#{group_id}"
      headers = token_header
      params = {}
      [:groupname, :description, :maxusers].each do |sym|
        params.merge!({ sym => group_params[sym] }) if group_params[sym]
      end
      uri, req = @http_client.put_request(url, params, headers)
      http_submit(uri, req)
    end

    # 删除群组
    def del_group(group_id)
      url = "#{@base_url}/chatgroups/#{group_id}"
      headers = token_header
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 获取群组中的所有成员
    def group_members(group_id)
      url = "#{@base_url}/chatgroups/#{group_id}/users"
      headers = token_header
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 群组加人[单个]
    # FIXME
    def add_member(group_id, username)
      url = "#{@base_url}/chatgroups/#{group_id}/users/#{username}"
      headers = token_header
      uri, req = @http_client.post_request url, nil, headers
      http_submit uri, req
    end

    # 群组加人[批量]
    def add_members(group_id, usernames = [])
      url = "#{@base_url}/chatgroups/#{group_id}/users"
      headers = token_header
      params = { usernames: usernames }
      uri, req = @http_client.post_request url, params, headers
      http_submit uri, req
    end

    # 群组减人
    def del_member(group_id, username)
      url = "#{@base_url}/chatgroups/#{group_id}/users/#{username}"
      headers = token_header
      uri, req = @http_client.del_request url, nil, headers
      http_submit uri, req
    end

    # 获取一个用户参与的所有群组
    def user_gropus(username)
      url = "#{@base_url}/users/#{username}/joined_chatgroups"
      headers = token_header
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # ==========================================================================
    ## 聊天室管理

    # 创建聊天室
    def create_room(room = {})
      url = "#{@base_url}/chatrooms"
      headers = token_header
      maxusers = room[:maxusers] || 200
      params = {
        name: room[:name],
        description: room[:description],
        maxusers: maxusers,
        owner: room[:owner]
      }
      params.merge!({ members: room[:members] }) if room[:members]
      uri, req = @http_client.post_request url, params, headers
      http_submit uri, req
    end

    # 修改聊天室信息
    def update_room_info(room_id, room_params)
      url = "#{@base_url}/chatrooms/#{room_id}"
      headers = token_header
      params = {}
      [:name, :description, :maxusers].each do |sym|
        params.merge!({ sym => room_params[sym] }) if room_params[sym]
      end
      uri, req = @http_client.put_request url, params, headers
      http_submit uri, req
    end

    # 删除聊天室
    def del_room(room_id)
      url = "#{@base_url}/chatrooms/#{room_id}"
      headers = token_header
      uri, req = @http_client.del_request url, nil, headers
      http_submit uri, req
    end

    # 获取app中所有的聊天室
    def rooms
      url = "#{@base_url}/chatrooms"
      headers = token_header
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # 获取一个聊天室详情
    def room_info(room_id)
      url = "#{@base_url}/chatrooms/#{room_id}"
      headers = token_header
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # 获取用户加入的聊天室
    def user_rooms(username)
      url = "#{@base_url}/users/#{username}/joined_chatrooms"
      headers = token_header
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # 添加聊天室成员[单个]
    def room_add_member(room_id, username)
      url = "#{@base_url}/chatrooms/#{room_id}/users/#{username}"
      headers = token_header
      uri, req = @http_client.post_request url, nil, headers
      http_submit uri, req
    end

    # 删除聊天室成员[单个]
    def room_del_member(room_id, username)
      url = "#{@base_url}/chatrooms/#{room_id}/users/#{username}"
      headers = token_header
      uri, req = @http_client.del_request url, nil, headers
      http_submit uri, req
    end

    # 添加禁言
    def room_mute_members(room_id, usernames, mute_duration)
      url = "#{@base_url}/chatrooms/#{room_id}/mute"
      headers = token_header
      params = {
        usernames: usernames,
        mute_duration: mute_duration
      }
      uri, req = @http_client.post_request url, params, headers
      http_submit uri, req
    end

    # 移除禁言
    def room_del_mute_members(room_id, usernames)
      url = "#{@base_url}/chatrooms/#{room_id}/mute/#{usernames.join(',')}"
      headers = token_header
      uri, req = @http_client.del_request url, nil, headers
      http_submit uri, req
    end

    private

    def token_header
      authorization = "Bearer " + token
      { 'Authorization' => authorization }
    end

    def http_submit(uri, req)
      res = @http_client.submit(uri, req)
      res_hash = JSON.parse res.body
      res_hash = res_hash.kind_of?(Array) ? res_hash.map(&:deep_symbolize_keys!) : res_hash.deep_symbolize_keys!
      res_hash[:http_code] = res.code
      res_hash
    end
  end
end
