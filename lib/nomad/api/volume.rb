require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Job} methods.
    # @return [Job]
    def volume
      @volume ||= Volume.new(self)
    end
  end

  class Volume < Request
    # Get the address and port of the current leader for this region
    #
    # @example
    #   Nomad.volume.list #=> [#<VolumeItem ...>]
    #
    # @param [String] type
    # @param [String] node_id
    # @param [String] plugin_id
    #
    # @return [Array<VolumeItem>]
    def list(options = {type: :csi})
      json = client.get("/v1/volumes", options)
      return json.map { |item| VolumeItem.decode(item) }
    end
    # @param [String] type
    # @param [String] node_id
    # @param [String] plugin_id
    #
    # @return <VolumeItem>
    def read(volume_id, **options)
      json = client.get("/v1/volume/csi/#{CGI.escape(volume_id)}", options)
      return VolumeItem.decode(json)
    end

    def register(volume_id, contents, **options)
      body = contents.is_a?(Hash) ? JSON.fast_generate(contents) : contents
      client.put("/v1/volume/csi/#{CGI.escape(volume_id)}", body, options)
      true
    end

    # @param [Boolean] force
    def delete(volume_id, **options)
      client.delete("/v1/volume/csi/#{CGI.escape(volume_id)}", options)
      true
    end
  end

  class VolumeItem < Response
    # @!attribute [r] id
    #   The volume id.
    #   @return [String]
    field :ID, as: :id, load: :string_as_nil

    # @!attribute [r] external_id
    #   The volume external_id.
    #   @return [String]
    field :ExternalID, as: :external_id, load: :string_as_nil

    # @!attribute [r] namespace
    #   The volume namespace.
    #   @return [String]
    field :Namespace, as: :namespace, load: :string_as_nil

    # @!attribute [r] name
    #   The volume name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] topologies
    #   The volume topologies.
    #   @return [Topologies]
    field :Topologies, as: :topologies, load: :nil_as_array

    # @!attribute [r] access_mode
    #   The volume access_mode.
    #   @return [String]
    field :AccessMode, as: :access_mode, load: :string_as_nil

    # @!attribute [r] attachment_mode
    #   The volume attachment_mode.
    #   @return [String]
    field :AttachmentMode, as: :attachment_mode, load: :string_as_nil

    # @!attribute [r] schedulable
    #   The volume schedulable.
    #   @return [Bool]
    field :Schedulable, as: :schedulable

    # @!attribute [r] plugin_id
    #   The volume plugin_id.
    #   @return [String]
    field :PluginID, as: :plugin_id, load: :string_as_nil

    # @!attribute [r] provider
    #   The volume provider.
    #   @return [String]
    field :Provider, as: :provider, load: :string_as_nil

    # @!attribute [r] controller_required
    #   The volume controller_required.
    #   @return [Bool]
    field :ControllerRequired, as: :controller_required

    # @!attribute [r] controllers_healthy
    #   The volume controllers_healthy.
    #   @return [Topologies]
    field :ControllersHealthy, as: :controllers_healthy

    # @!attribute [r] controllers_expected
    #   The volume controllers_expected.
    #   @return [Int]
    field :ControllersExpected, as: :controllers_expected

    # @!attribute [r] nodes_healthy
    #   The volume nodes_healthy.
    #   @return [Int]
    field :NodesHealthy, as: :nodes_healthy

    # @!attribute [r] nodes_expected
    #   The volume nodes_expected.
    #   @return [Int]
    field :NodesExpected, as: :nodes_expected

    # @!attribute [r] resource_exhausted
    #   The volume resource_exhausted.
    #   @return [Int]
    field :ResourceExhausted, as: :resource_exhausted

    # @!attribute [r] create_index
    #   The volume create_index.
    #   @return [Int]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The volume modify_index.
    #   @return [Int]
    field :ModifyIndex, as: :modify_index

    field :RequestedCapabilities, as: :requested_capabilities, load: ->(item) {
      (item || []).map { |rc| VolumeRequestedCapabilities.decode(rc) }
    }
    field :Allocations, as: :allocations, load: ->(item) { (item || []).map { |a| Alloc.decode(a) } }
    field :ReadAllocs, as: :read_allocs
    field :WriteAllocs, as: :write_allocs
    field :Capacity, as: :capacity
    field :CloneID, as: :clone_id
    field :Context, as: :context, load: ->(item) { VolumeContext.decode(item) }
  end

  class VolumeRequestedCapabilities < Response
    field :AccessMode, as: :access_mode, load: :string_as_nil
    field :AttachmentMode, as: :attachment_mode, load: :string_as_nil
  end

  class VolumeContext < Response
    field :Share, as: :share, load: :string_as_nil
    field :Server, as: :server, load: :string_as_nil
  end
end
