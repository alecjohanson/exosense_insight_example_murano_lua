--

local Trello_Insight = {}

Trello_Insight.functions = {
  create_card = {
    name = "create_card",
    description = "Creates a card",
    constants = {
      {
        name = "idList",
        type = "string"
      },
      {
        name = "apiKey",
        description = "API Key provided from Trello",
        type = "string"
      },
      {
        name = "token",
        description = "Token provided by Trello",
        type = "string"
      },
      {
        name = "max_temp",
        description = "temp threshold",
        type = "TEMPERATURE"
      }
    },
    inlets = {
      {
        name = 'Input Signal',
        --tag = 'x',
        --primitive_type = 'NUMERIC',
        data_type = 'TEMPERATURE',
      }
    },
    fn = function(request)
      log.critical("REQUEST: " .. to_json(request))
      local dataIN = request.data
      local constants = request.args.constants
      local id = request.id

      local current_state = "Good"
      if dataIn > max_temp then
        current_state = "Bad"
        log.critical("State Bad: ")
      end

      local previous_state = Keystore.get({key=id})
      if previous_state == "Good" and current_state == "Bad" then
        params = {Name="Generated from Insight",Description="Description here",idList=idList,key=apiKey,token=token,keepFromSource="all"}
        url = "https://api.trello.com/1/cards"
        local response = Http.post({url=url, params=params})
        print(response.status_code)
      end
      end
  }
}
function Trello_Insight.info()
  return {
    name = 'Trello',
    description = 'Trello Card Creator',
    group_id_required = false,
    wants_lifecycle_events = false,
  }
end

function Trello_Insight.listInsights()
  local insights = {}
  for k,v in pairs(Trello_Insight.functions) do
    v.fn = nil
    v.id = k
    table.insert(insights, v)
  end
  return {
    total = #insights,
    count = #insights,
    insights = insights,
  }
end

function Trello_Insight.infoInsight(request)
  local found = Trello_Insight.functions[request.function_id]
  if found == nil then
    return nil, {
      name='Not Implemented',
      message = 'Function "' .. tostring(request.function_id) .. '" is not implemented'
    }
  end
  found.id = request.function_id
  found.fn = nil
  return found
end

function Trello_Insight.lifecycle(request)
  log.debug("LIFECYCLE: " .. to_json(request))
  return {}
end

function Trello_Insight.process(request)
  log.debug("PROCESS: " .. to_json(request))
  local found = Trello_Insight.functions[request.args.function_id]
  if found == nil then
    return nil, {
      name='Not Implemented',
      message = 'Function "' .. tostring(request.function_id) .. '" is not implemented'
    }
  end
  return found.fn(request)
end

return Trello_Insight
