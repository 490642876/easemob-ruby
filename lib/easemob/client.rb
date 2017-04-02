require_relative 'http_client'
require 'json'
require 'active_support/core_ext/hash/keys'

module Easemob
  class Client
    attr_reader :client_id, :client_secret, :host, :org_name, :app_name, :base_url
    def initialize
      @client_id = Easemob.configuration.client_id
      @client_secret = Easemob.configuration.client_secret
      @host = Easemob.configuration.host || 'https://a1.easemob.com'
      @org_name = Easemob.configuration.org_name
      @app_name = Easemob.configuration.app_name
      @http_client = HttpClient.new
      @base_url = "#{@host}/#{@org_name}/#{@app_name}"
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
    def create_user(token, username, password, nickname = nil)
      url = "#{@base_url}/users"
      headers = token_header(token)
      params = {
        username: username,
        password: password,
        nickname: nickname
      }
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 注册IM用户[批量]
    def create_users(token, users = [])
      url = "#{@base_url}/users"
      headers = token_header(token)
      params = users
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 获取IM用户[单个]
    def get_user(token, username)
      url = "#{@base_url}/users/#{username}"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 获取IM用户[批量]
    def get_users(token, limit = 10)
      url = "#{@base_url}/users"
      headers = token_header(token)
      params = { limit: limit }
      uri, req = @http_client.get_request(url, params, headers)
      http_submit(uri, req)
    end

    # 删除IM用户[单个]
    def destroy_user(token, username)
      url = "#{@base_url}/users/#{username}"
      headers = token_header(token)
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 删除IM用户[批量]
    def destroy_users(token, limit = 2)
      url = "#{@base_url}/users"
      headers = token_header(token)
      params = { limit: limit }
      uri, req = @http_client.del_request(url, params, headers)
      http_submit(uri, req)
    end

    # 重置IM用户密码
    def reset_password(token, username, newpassword)
      url = "#{@base_url}/users/#{username}/password"
      headers = token_header(token)
      params = { newpassword: newpassword }
      uri, req = @http_client.put_request(url, params, headers)
      http_submit(uri, req)
    end

    # 修改用户昵称
    def reset_nickname(token, username, nickname)
      url = "#{@base_url}/users/#{username}"
      headers = token_header(token)
      params = { nickname: nickname }
      uri, req = @http_client.put_request(url, params, headers)
      http_submit(uri, req)
    end

    # 给IM用户的添加好友
    # FIXME
    def add_friend(token, owner_username, friend_username)
      url = "#{@base_url}/users/#{owner_username}/contacts/users/#{friend_username}"
      headers = token_header(token)
      uri, req = @http_client.post_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 解除IM用户的好友关系
    # FIXME
    def remove_friend(token, owner_username, friend_username)
      url = "#{@base_url}/users/#{owner_username}/contacts/users/#{friend_username}"
      headers = token_header(token)
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查看好友
    def friends(token, owner_username)
      url = "#{@base_url}/users/#{owner_username}/contacts/users"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 往IM用户的黑名单中加人
    def block(token, owner_username, usernames = [])
      url = "#{@base_url}/users/#{owner_username}/blocks/users"
      headers = token_header(token)
      params = { usernames: usernames }
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # 获取IM用户的黑名单
    def black_list(token, owner_username)
      url = "#{@base_url}/users/#{owner_username}/blocks/users"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 从IM用户的黑名单中减人
    def unblock(token, owner_username, blocked_username)
      url = "#{@base_url}/users/#{owner_username}/blocks/users/#{blocked_username}"
      headers = token_header(token)
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查看用户在线状态
    def online_status(token, username)
      url = "#{@base_url}/users/#{username}/status"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查询离线消息数
    def offline_msg_count(token, owner_username)
      url = "#{@base_url}/users/#{owner_username}/offline_msg_count"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 查询某条离线消息状态
    def offline_msg_status(token, username, msg_id)
      url = "#{@base_url}/users/#{username}/offline_msg_status/#{msg_id}"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 用户账号禁用
    def deactivate_user(token, username)
      url = "#{@base_url}/users/#{username}/deactivate"
      headers = token_header(token)
      uri, req = @http_client.post_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 用户账号解禁
    def activate_user(token, username)
      url = "#{@base_url}/users/#{username}/activate"
      headers = token_header(token)
      uri, req = @http_client.post_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 强制用户下线
    def disconnect_user(token, username)
      url = "#{@base_url}/users/#{username}/disconnect"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # ==========================================================================
    ## 聊天记录

    # 导出聊天记录
    def export_chat_msgs(token, ql = nil, limit = nil, cursor = nil)
      url = "#{@base_url}/chatmessages"
      headers = token_header(token)
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
    def send_cmd(token, username, action, ext_attrs={}) 
      url = "#{@base_url}/messages"
      headers = token_header(token)
      params = {
        target_type: "users",
        target: [username],
        msg: {
          type: "cmd",
          action: action,
        }
      }
      params.merge(ext: ext_attrs) if ext_attrs.length > 0
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    def send_text(token, username, text, ext_attrs={}) 
      url = "#{@base_url}/messages"
      headers = token_header(token)
      params = {
        target_type: "users",
        target: [username],
        msg: {
          type: "txt",
          msg: text,
        }
      }
      params.merge(ext: ext_attrs) if ext_attrs.length > 0
      uri, req = @http_client.post_request(url, params, headers)
      http_submit(uri, req)
    end

    # ==========================================================================
    ## 群组管理

    # 获取app中所有的群组
    def groups(token)
      url = "#{@base_url}/chatgroups"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 获取一个或者多个群组的详情
    def groups_details(token, group_ids = [])
      params = group_ids.join(',')
      url = "#{@base_url}/chatgroups/#{params}"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 创建一个群组
    def create_group(token, group_params = {})
      url = "#{@base_url}/chatgroups"
      headers = token_header(token)
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
    def update_group_info(token, group_id, group_params = {})
      url = "#{@base_url}/chatgroups/#{group_id}"
      headers = token_header(token)
      params = {}
      [:groupname, :description, :maxusers].each do |sym|
        params.merge!({ sym => group_params[sym] }) if group_params[sym]
      end
      uri, req = @http_client.put_request(url, params, headers)
      http_submit(uri, req)
    end

    # 删除群组
    def del_group(token, group_id)
      url = "#{@base_url}/chatgroups/#{group_id}"
      headers = token_header(token)
      uri, req = @http_client.del_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 获取群组中的所有成员
    def group_members(token, group_id)
      url = "#{@base_url}/chatgroups/#{group_id}/users"
      headers = token_header(token)
      uri, req = @http_client.get_request(url, nil, headers)
      http_submit(uri, req)
    end

    # 群组加人[单个]
    # FIXME
    def add_member(token, group_id, username)
      url = "#{@base_url}/chatgroups/#{group_id}/users/#{username}"
      headers = token_header token
      uri, req = @http_client.post_request url, nil, headers
      http_submit uri, req
    end

    # 群组加人[批量]
    def add_members(token, group_id, usernames = [])
      url = "#{@base_url}/chatgroups/#{group_id}/users"
      headers = token_header token
      params = { usernames: usernames }
      uri, req = @http_client.post_request url, params, headers
      http_submit uri, req
    end

    # 群组减人
    def del_member(token, group_id, username)
      url = "#{@base_url}/chatgroups/#{group_id}/users/#{username}"
      headers = token_header token
      uri, req = @http_client.del_request url, nil, headers
      http_submit uri, req
    end

    # 获取一个用户参与的所有群组
    def user_gropus(token, username)
      url = "#{@base_url}/users/#{username}/joined_chatgroups"
      headers = token_header token
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # ==========================================================================
    ## 聊天室管理

    # 创建聊天室
    def create_room(token, room = {})
      url = "#{@base_url}/chatrooms"
      headers = token_header token
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
    def update_room_info(token, room_id, room_params)
      url = "#{@base_url}/chatrooms/#{room_id}"
      headers = token_header token
      params = {}
      [:name, :description, :maxusers].each do |sym|
        params.merge!({ sym => room_params[sym] }) if room_params[sym]
      end
      uri, req = @http_client.put_request url, params, headers
      http_submit uri, req
    end

    # 删除聊天室
    def del_room(token, room_id)
      url = "#{@base_url}/chatrooms/#{room_id}"
      headers = token_header token
      uri, req = @http_client.del_request url, nil, headers
      http_submit uri, req
    end

    # 获取app中所有的聊天室
    def rooms(token)
      url = "#{@base_url}/chatrooms"
      headers = token_header token
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # 获取一个聊天室详情
    def room_info(token, room_id)
      url = "#{@base_url}/chatrooms/#{room_id}"
      headers = token_header token
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    # 获取用户加入的聊天室
    def user_rooms(token, username)
      url = "#{@base_url}/users/#{username}/joined_chatrooms"
      headers = token_header token
      uri, req = @http_client.get_request url, nil, headers
      http_submit uri, req
    end

    private

    def token_header(token)
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
