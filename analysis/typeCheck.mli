(** Copyright (c) 2016-present, Facebook, Inc.

    This source code is licensed under the MIT license found in the
    LICENSE file in the root directory of this source tree. *)

open Core

open Ast
open Statement

module Error = AnalysisError


val resolve_exports: resolution: Resolution.t -> Reference.t -> Reference.t

module type Context = sig
  val configuration: Configuration.Analysis.t
  val define: Define.t Node.t
end

module type Signature = sig
  type t
  [@@deriving eq]

  val create
    :  ?bottom: bool
    -> resolution: Resolution.t
    -> ?resolution_fixpoint: ResolutionSharedMemory.annotation_map Int.Map.Tree.t
    -> unit
    -> t

  val errors: t -> Error.t list
  val coverage: t -> Coverage.t

  val initial: resolution: Resolution.t -> unit -> t

  (* Visible for testing. *)
  type resolved = {
    state: t;
    resolved: Type.t;
  }

  val parse_and_check_annotation: ?bind_variables:bool ->  state: t -> Expression.t -> t * Type.t
  val forward_expression: state: t -> expression: Expression.t -> resolved
  val forward_statement: state: t -> statement: Statement.t -> t

  include Fixpoint.State with type t := t
end

module State(Context: Context): Signature

val resolution
  :  (module Environment.Handler)
  -> ?annotations: Annotation.t Reference.Map.t
  -> unit
  -> Resolution.t

val resolution_with_key
  :  environment: (module Environment.Handler)
  -> parent: Reference.t option
  -> name: Reference.t
  -> key: int option
  -> Resolution.t

val name: string

val run
  :  configuration: Configuration.Analysis.t
  -> environment: (module Environment.Handler)
  -> source: Source.t
  -> Error.t list
